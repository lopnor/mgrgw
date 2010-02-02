package Mgrgw::Controller::Favorites;
use Ark 'Controller';
with 'Mgrgw::ActionClass::BasicAuth',
    'Mgrgw::ActionClass::API';

use Mgrgw::Models;

sub auto :Private :BasicAuth {1}

sub index :API {
    my ($self, $c) = @_;
    $c->stash->{json} = [];
}

1;

