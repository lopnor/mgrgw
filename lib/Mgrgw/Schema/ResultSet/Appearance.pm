package Mgrgw::Schema::ResultSet::Appearance;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Mgrgw::Models;
use DateTime;

sub record {
    my ($self, $user, $address) = @_;

    my $time = DateTime->now->add(minutes => -10);

    my $txn_guard = $self->result_source->schema->txn_scope_guard;

    my $found = $self->search(
        {
            user_id => $user->id,
            address => $address,
            updated_at => { '>=' => $time->strftime("%F %T") },
        },
        {
            order_by => {-desc => 'updated_at'}
        }
    )->first;

    if ($found) {
        $found->update({updated_at => DateTime->now});
    } else {
        $found = $self->create(
            {
                user_id => $user->id,  
                address => $address,
            }
        );
    }
    $txn_guard->commit;
    $found;
}

1;
