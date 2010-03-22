package Mgrgw::Form::Token::Revoke;
use Ark 'Form';

param 'token' => (
    type => 'hidden',
);

sub custom_validation {
    my ($self, $form) = @_;
    $form->param('token') eq $self->context->stash->{token}->token
        or $form->set_error('token' => 'NOT_NULL');
}

1;
