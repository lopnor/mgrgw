package Mgrgw::ActionClass::Webhook;
use Any::Moose '::Role';
use Mgrgw::Models;
use URI;

after ACTION => sub {
    my ($next, $self, $action, $c, @args) = @_;
    my $user = $c->stash->{user} or return;
    for my $type (@{$action->attributes->{Webhook}}) {
        my $hook = models('Schema::Webhook')->search(
            {
                user_id => $user->id,
                type => $type,
            }
        )->single or next;
        my $uri = URI->new($hook->uri);
    }
};

no Any::Moose '::Role';

sub _parse_Webhook_attr {
    my ($self, $name, $value) = @_;
    return Webhook => $value;
}

1;
