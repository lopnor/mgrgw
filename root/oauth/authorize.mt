? extends 'base';
? my $app = $s->{token}->application;
? block content => sub {
<table>
<tr><th>Application Name</th><td><?= $app->name ?></td></tr>
<tr><th>Author</th><td><?= $app->user->username ?></td></tr>
<tr><th>Callback URL</th><td><?= $app->callback_url || 'not set' ?></td></tr>

</table>
<?= include('form', $s->{form}, 'verify this app', '?') ?>
? };
