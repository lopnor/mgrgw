package Mgrgw::Controller::Statuses;
use Ark 'Controller';
with 'Mgrgw::ActionClass::API',
    'Mgrgw::ActionClass::Protected';

use Mgrgw::Models;

sub auto :Private :Protected {
    1;
}

sub update :API {
    my ($self, $c) = @_;
    {
        $c->req->method eq 'POST' or last;
        my $status = models('Schema::Status')->create_from_req($c->req) or last;
        $c->stash->{json} = $status->format;
        return;
    }
    $c->res->status(403);
    $c->res->body('forbidden');
}

sub replies :API {
    my ($self, $c) = @_;
    $c->stash->{json} = [];
}

sub home_timeline :API {
    my ($self, $c) = @_;

    my $since = $c->req->param('since_id');
    my $max = $c->req->param('max_id');

    my @statuses = map {
        $_->format
    } models('Schema::Status')->search(
        {
            user_id => $c->stash->{user}->id,
            $since ? ('me.id' => {'>' => $since}) : (),
            $max ? ('me.id' => {'<=' => $max}) : (),
        },
        {
            order_by => { -desc => 'me.id' },
            rows => $c->req->param('count') || 20,
            prefetch => 'user',
        }
    );

    $c->stash->{json} = \@statuses;
}

1;
