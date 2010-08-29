package Mgrgw::Form::Settings;
use Ark 'Form';

param 'fullname' => (
    label => 'Full Name',
    type  => 'text',
    constraints => [
        'NOT_NULL',
    ],
);

param 'password' => (
    label => 'Password (for BasicAuth/xAuth clients)',
    type => 'password',
);

1;
