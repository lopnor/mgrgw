package Mgrgw::Schema::ResultSet::Webhook;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub create_from_form {
    my ($self, $user, $form) = @_;
    my $txn_guard = $self->result_source->schema->txn_scope_guard;
    my $item = $self->create(
        {
            user_id => $user->id,
            %{$form->params},
        }
    );
    $txn_guard->commit;
    $item;
}

sub update_by_form {
    my ($self, $item, $form) = @_;

    my $txn_guard = $self->result_source->schema->txn_scope_guard;
    $item->update($form->params);
    $txn_guard->commit;

    $item;
}

1;
