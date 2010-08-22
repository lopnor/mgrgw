package Mgrgw::ActionClass::LoginUser;
use Any::Moose '::Role';
use Mgrgw::Models;

around ACTION => sub {
    my ($next, $self, $action, $c, @args) = @_;

    if ($action->attributes->{LoginUser}->[0]) {
#        my $c = $self->context;
        
        my $user = $c->user;
        unless ($user) {
            $c->session->set(nexturl => $c->req->uri);
            $c->redirect($c->uri_for('/login'));
            return;
        }
        unless ($user->obj) {
            $c->session->set(nexturl => $c->req->uri);
            $c->redirect($c->uri_for('/setup'));
            return;
        }
    }

    $next->($self, $action, $c, @args);
};

sub _parse_LoginUser_attr {
    my ($self, $name, $value) = @_;
    return LoginUser => 1;
}

1;
