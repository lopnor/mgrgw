package Mgrgw::Schema::ResultSet::Token;
use strict;
use warnings;
use base 'Mgrgw::Schema::ResultSet';
use Net::OAuth;
$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
use Mgrgw::Models;

sub create_request_token {
    my ($self, $req) = @_;

    my $type = "request token";

    my $txn_guard = $self->result_source->schema->txn_scope_guard;

    my $app = models('Schema::Application')->search(
        {
            consumer_key => $req->param('oauth_consumer_key')
        }
    )->single or return;

    my $uri = $req->uri->clone;
    $uri->query_form([]);

    my $oauth = Net::OAuth->request($type)->from_hash(
        $req->parameters->as_hashref,
        request_method => $req->method,
        request_url => $uri,
        consumer_secret => $app->consumer_secret,
    );
    $oauth->verify or return;

    my $token = $self->create(
        {
            application_id => $app->id,
            token => $self->sha1_hex,
            secret => $self->sha1_hex,
            type => $type,
        }
    );

    my $res = Net::OAuth->response($type)->new(
        token => $token->token,
        token_secret => $token->secret,
        callback_confirmed => 'false',
    );
    $txn_guard->commit;

    return $res->to_post_body;
}

sub token_to_authorize {
    my ($self, $req) = @_;
    return $self->search(
        {
            token => $req->param('oauth_token'),
            type => 'request token',
            verifier => undef,
        }
    )->single;
}

sub authorize_token {
    my ($self, $args) = @_;
    my $token = $args->{token};
    my $user = $args->{user};

    my $rand;
    $rand .= int(rand(10)) for (1 .. 16);

    $token->update( 
        { 
            verifier => $rand, 
            user_id  => $user->id,
        } 
    );
    if ( my $cb = $token->application->callback_url ) {
        return Net::OAuth->response('user auth')->new(
            token => $token->token,
            verifier => $token->verifier,
        )->to_url($cb);
    }
}

sub create_access_token {
    my ($self, $req) = @_;

    my $type = 'access token';
    my $uri = $req->uri->clone;
    $uri->query_form([]);

    my $txn_guard = $self->result_source->schema->txn_scope_guard;
    my $hash = $self->oauth_request_hash($req);

    my ($app, $user_id);
    if (($hash->{x_auth_mode} || '') eq 'client_auth') {
        $app = models('Schema::Application')->search(
            { consumer_key => $hash->{oauth_consumer_key} }
        )->single 
            or return;
        my $user = models('Schema::User')->find(
            { username => ($hash->{x_auth_username}||'') }
        ) 
            or return;
        $user_id = $user->id;
        $user->check_password(($hash->{x_auth_password}||'') )
            or return;
        my $oauth = Net::OAuth->request('XauthAccessToken')->from_authorization_header(
            $req->header('authorization'),
            request_url => $uri,
            request_method => $req->method,
            consumer_secret => $app->consumer_secret,
        );
        $oauth->verify or return;
    } else {
        my $req_token = $self->search(
            {
                token => $hash->{oauth_token},
                verifier => $hash->{oauth_verifier},
                type => 'request token',
            }
        )->single or return;

        $app = $req_token->application or return;
        $user_id = $req_token->user_id;
        $app->consumer_key eq $hash->{oauth_consumer_key} or return;

        my $oauth = Net::OAuth->request($type)->from_hash(
            $req->parameters->as_hashref,
            request_method => $req->method,
            request_url => $uri,
            token_secret => $req_token->secret,
            consumer_secret => $app->consumer_secret,
        );
        $oauth->verify or return;
        $req_token->delete;
    }

    my $token = $self->create(
        {
            application_id => $app->id,
            user_id => $user_id,
            token => $self->sha1_hex,
            secret => $self->sha1_hex,
            type => $type,
        }
    );

    my $res = Net::OAuth->response($type)->new(
        token => $token->token,
        token_secret => $token->secret,
        extra_params => {
            user_id => $token->user_id,
            screen_name => $token->user->username,
        },
    );
    $txn_guard->commit;

    return $res->to_post_body;
}

sub protected_resource_request {
    my ($self, $req) = @_;
    my $uri = $req->uri->clone;
    $uri->query_form([]);

    my $hash = $self->oauth_request_hash($req);

    my $token = $self->search( 
        { 
            token => $hash->{oauth_token},
            type => 'access token',
        }
    )->single or return;
    my $app = $token->application;
    $app->consumer_key eq $hash->{oauth_consumer_key} or return;

    my $params = {
        request_method => $req->method,
        request_url => $uri,
        token_secret => $token->secret,
        consumer_secret => $app->consumer_secret,
    };
    my $oauth = do {
        if (my $header = $req->header('authorization')) {
            Net::OAuth->request('protected resource')->from_authorization_header(
                $req->header('authorization'),
                %$params,
                extra_params => $req->parameters->as_hashref,
            );
        } else {
            Net::OAuth->request('protected resource')->from_hash(
                $hash,
                %$params,
            );
        }
    };
    $oauth->verify or return;
    return $token;
}

sub oauth_request_hash {
    my ($self, $req) = @_;
    if (my $header = $req->header('authorization')) {
        my $hash = { split(/[=,]/, [split(/\s/, $header)]->[1]) };
        $hash->{$_} =~ s{^"|"$}{}g for keys %$hash;
        return $hash;
    } else {
        return $req->parameters->as_hashref;
    }
}

1;
