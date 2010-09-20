package Mgrgw::Form::Webhook::Create;
use Ark 'Form';

param 'uri' => (
    label => 'Webhook endpoint uri',
    type => 'url',
);

param 'type' => (
    label => 'Webhook type',
    type => 'ChoiceField',
    choices => [
        'after_update', 'after update',
    ],
);

1;
