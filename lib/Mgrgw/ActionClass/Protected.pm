package Mgrgw::ActionClass::Protected;
use Any::Moose '::Role';
use MIME::Base64 ();
use Mgrgw::Models;
use DateTime;

around ACTION => sub {
    my ($next, $self, $action, $c, @args) = @_;

    if (my $realm = $action->attributes->{Protected}->[0]) {
#        my $c = $self->context;
        my ($user, $address);
        {
            if ($c->user && $c->user->obj) {
                $user = $c->user->obj;
                $address = $c->req->address;
                last;
            }
            $user = $c->req->user and last;
            my $auth = $c->req->env->{HTTP_AUTHORIZATION};
            if (($auth || '') =~ /^Basic (.*)$/) {
                $user = models('Schema::User')->basic_auth($auth);
                $address = $c->req->user_agent;
            } else {
                my $token = models('Schema::Token')->protected_resource_request($c->req)
                    or last;
                $user = $token->user;
                $c->stash->{application} = $token->application;
                $address = $token->application->name;
            }
        }
        if ($user) {
            $c->req->env->{REMOTE_USER} = $user->username;
            $c->stash->{user} = $user;
            $c->stash->{appearance} 
                = models('Schema::Appearance')->record($user,$address);
        } else {
            $c->res->status(401);
            $c->res->header('WWW-Authenticate' => "Basic realm=\"$realm\"");
            $c->res->body('Authorization required');
            return;
        }
    }

    $next->($self, $action, $c, @args);
};

no Any::Moose '::Role';

sub _parse_Protected_attr {
    my ($self, $name, $value) = @_;
    return Protected => $value || 'Protected';
}

1;
