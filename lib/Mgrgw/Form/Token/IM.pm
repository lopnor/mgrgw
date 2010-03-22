package Mgrgw::Form::Token::IM;
use Ark 'Form';
use Mgrgw::Models;

param 'token' => (
    type => 'hidden',
);

sub custom_validation {
    my ($self, $form) = @_;
    my $c = $self->context;

    models('Schema::Token')->search(
        {
            user_id => $c->user->obj->id,
            token   => $form->param('token'),
            type    => 'request token',
        }
    )
        or $form->set_error('token' => 'NOT_NULL');
}

1;
