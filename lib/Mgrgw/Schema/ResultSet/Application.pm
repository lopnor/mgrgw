package Mgrgw::Schema::ResultSet::Application;
use strict;
use warnings;
use base 'Mgrgw::Schema::ResultSet';

sub create_from_form {
    my ($self, $user, $form) = @_;


    my $txn_guard = $self->result_source->schema->txn_scope_guard;

    my $key = $self->generate_key;

    my $app = $self->create(
        {
            user_id => $user->id,
            %{$form->params},
            consumer_key => $key,
            consumer_secret => $self->sha1_hex,
        }
    );

    $txn_guard->commit;
    $app;
}

sub update_by_form {
    my ($self, $app, $form) = @_;

    my $fields = $form->params;

    my $txn_guard = $self->result_source->schema->txn_scope_guard;

    if (delete $fields->{regenerate}) {
        $fields->{consumer_key} = $self->generate_key;
        $fields->{consumer_secret} = $self->sha1_hex;
    }
    $app->update($fields);

    $txn_guard->commit;
    $app;
}

sub generate_key {
    my ($self) = @_;

    my $key;
    while (1) {
        $key = $self->sha1_hex;
        $self->find({consumer_key => $key}) or last;
    };
    return $key;
}

1;
