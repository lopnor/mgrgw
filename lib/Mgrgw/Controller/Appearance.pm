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

    my @result = models('Schema::Appearance')->search(
        {
            user_id => $c->stash->{user}->id,
        },
        {
            order_by => { -desc => [qw(updated_at id)] },
            rows => $c->req->param('count') || 20,
        }
    );
    my $hash;
    for (@result) {
        if (my $old = $hash->{$_->created_at}) {
            if ($_->updated_at > $old->updated_at) {
                $hash->{$_->created_at} = $_;
            }
        } else {
            $hash->{$_->created_at} = $_;
        }
    }
    $c->stash->{json} = [map {$hash->{$_}->format} sort {$b <=> $a} keys %$hash];
}

sub current :API {
    my ($self, $c) = @_;

    $c->stash->{json} = $c->stash->{appearance}->format;
}

1;
