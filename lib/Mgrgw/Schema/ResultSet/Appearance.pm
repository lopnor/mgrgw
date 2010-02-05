package Mgrgw::Schema::ResultSet::Appearance;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Mgrgw::Models;
use DateTime;

sub record {
    my ($self, $user, $req) = @_;

    my $found = $self->current_appearance($user, $req);
    if ($found) {
        $found->update({updated_at => DateTime->now});
    } else {
        $self->create(
            {
                user_id => $user->id,  
                address => $req->address,
                user_agent => $req->user_agent,
            }
        );
    }
}

sub current_appearance {
    my ($self, $user, $req) = @_;
    $self->search(
        {
            user_id => $user->id,
            address => $req->address,
            user_agent => $req->user_agent,
            updated_at => { '>=' => DateTime->now->add(minutes => -10)->strftime("%F %T") },
        },
        {
            order_by => {-desc => 'updated_at'}
        }
    )->first;
}

1;
