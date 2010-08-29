? extends 'base';
? block content => sub {
You verified <?= $s->{token}->application->name ?>.</br>
PIN is <b><?= $s->{token}->verifier ?></b>.
? };
