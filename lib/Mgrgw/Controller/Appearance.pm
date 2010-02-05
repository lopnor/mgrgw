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

    my @result = map {$_->format}
    models('Schema::Appearance')->search(
        {
            user_id => $c->stash->{user}->id,
        },
        {
            order_by => { -desc => 'updated_at' },
            rows => $c->req->param('count') || 20,
        }
    );
    $c->stash->{json} = \@result;
}

sub current :API {
    my ($self, $c) = @_;

    $c->stash->{json} = $c->stash->{appearance}->format;
}

1;
