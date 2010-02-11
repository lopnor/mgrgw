package Mgrgw::Controller::Search;
use Ark 'Controller';
with 'Mgrgw::ActionClass::API',
    'Mgrgw::ActionClass::Protected';

use Mgrgw::Models;

sub auto :Private :Protected {
    1;
}

sub index :API {
    my ($self, $c) = @_;

    my $since = $c->req->param('since_id');
    my $max = $c->req->param('max_id');
    my $q = $c->req->param('q');

    unless ($q) {
        $c->res->status(403);
        $c->res->body('forbidden');
        $c->detach;
    }

    my @statuses = map {
        $_->format
    } models('Schema::Status')->search(
        {
            user_id => $c->stash->{user}->id,
            text => {like => "%$q%"},
            $since ? (id => {'>' => $since}) : (),
            $max ? (id => {'<=' => $max}) : (),
        },
        {
            order_by => { -desc => 'id' },
            rows => $c->req->param('count') || 20,
        }
    );

    $c->stash->{json} = \@statuses;
}

1;
