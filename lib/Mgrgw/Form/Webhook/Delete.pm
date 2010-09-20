package Mgrgw::Form::Webhook::Delete;
use Ark 'Form';

param 'token' => (
    type => 'hidden',
);

sub custom_validation {
    my ($self, $form) = @_;
    $form->param('token') eq $self->context->session->get('__form_delete_token')
        or $form->set_error('token' => 'NOT_NULL');
}

1;
