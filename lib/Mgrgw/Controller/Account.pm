package Mgrgw::Controller::Account;
use Ark 'Controller';
with 'Mgrgw::ActionClass::API',
    'Mgrgw::ActionClass::BasicAuth';

use Mgrgw::Models;

sub auto :Private :BasicAuth {
    1;
}

sub verify_credentials :API {
    my ($self, $c) = @_;
    my $u = $c->stash->{user};
    $c->stash->{json} = {
        user => {
            id => $u->id,
            name => $u->fullname,
            screen_name => $u->username,
        },
    };
}

1;
