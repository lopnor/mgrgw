package Mgrgw::Controller::Appearance;
use Ark 'Controller';
with 'Mgrgw::ActionClass::API',
    'Mgrgw::ActionClass::Protected';

use Mgrgw::Models;

sub auto :Private :Protected {
    1;
}

sub index :API {
    my ($self, $c) = @_;
    $c->stash->{json} = models('Schema::Appearance')->recent(
        $c->stash->{user},
        $c->req->parameters->as_hashref,
    );
}

sub current :API {
    my ($self, $c) = @_;

    $c->stash->{json} = $c->stash->{appearance}->format;
}

1;
