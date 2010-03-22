package Mgrgw::Controller::OAuth;
use Ark 'Controller';
with 'Ark::ActionClass::Form',
    'Mgrgw::ActionClass::LoginUser';

use Mgrgw::Models;

sub request_token :Local {
    my ($self, $c) = @_;
    my $token = models('Schema::Token')->create_request_token($c->req)
        or $c->detach('unauthorized');

    $c->res->body($token);
}

sub authorize :Local :LoginUser :Form('Mgrgw::Form::Authorize') {
    my ($self, $c) = @_;
    my $token = models('Schema::Token')->token_to_authorize($c->req)
        or $c->detach('default');
    if ($c->req->method eq 'POST' && $self->form->submitted_and_valid) {
        $c->detach('authorized', $token);
    }
    $self->form->fill($c->req);
}

sub authorized :Private {
    my ($self, $c, $token) = @_;
    my $cb = models('Schema::Token')->authorize_token(
        {
            token => $token,
            user  => $c->user->obj,
        }
    );
    if ($cb) {
        $c->redirect($cb);
    } else {
        $c->stash(
            {
                verifier => $token->verifier,
                __view_mt_template => 'oauth/authorized',
            }
        );
    }
}

sub authenticate :Local {
    my ($self, $c) = @_;

}

sub access_token :Local {
    my ($self, $c) = @_;

    my $token = models('Schema::Token')->create_access_token( $c->req )
        or $c->detach('unauthorized');

    $c->res->body($token);
}

sub unauthorized :Local {
    my ($self, $c) = @_;
    $c->res->status(401);
    $c->res->body('Unauthorized');
}

sub index :Path :LoginUser {}

sub load_token :LoginUser :Chained :PathPart('oauth') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    $c->stash->{token} = models('Schema::Token')->search(
        {
            user_id => $c->user->obj->id,
            id => $id,
            type => 'access token',
        }
    )->first;
    unless ($c->stash->{token}) {
        $c->res->status(403);
        $c->res->body('forbidden');
        $c->detach;
    }
}

sub revoke :Chained('load_token') :PathPart('') :Args(0) :Form('Mgrgw::Form::Token::Revoke') {
    my ($self, $c) = @_;
    if ($c->req->method eq 'POST' && $self->form->submitted_and_valid) {
        $c->stash->{token}->delete;
        $c->redirect($c->uri_for('/oauth'));
    }
    $self->form->fill({token => $c->stash->{token}->token});
}

1;

