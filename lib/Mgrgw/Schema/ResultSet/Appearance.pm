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
            order_by => {-desc => [qw(updated_at id)]}
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

sub recent {
    my ($self, $user, $params) = @_;

    my @result = models('Schema::Appearance')->search(
        {
            user_id => $user->id,
        },
        {
            order_by => { -desc => [qw(updated_at id)] },
            rows => $params->{count} || 20,
        }
    );
    my $hash;
    for (@result) {
        my $epoch = $_->created_at->epoch;
        if (my $old = $hash->{$epoch}) {
            if ($_->updated_at > $old->updated_at) {
                $hash->{$epoch} = $_;
            }
        } else {
            $hash->{$epoch} = $_;
        }
    }
    return [map {$hash->{$_}->format} reverse sort keys %$hash];
}

1;
