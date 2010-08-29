? extends 'base';
? block 'content' => sub {
? my $app = $s->{token}->application;
<table class="view">
? for my $attr (qw(name callback_url)) {
<tr>
<th><?= $attr ?></th>
<td><?= $app->$attr || 'undefined' ?></td>
</tr>
? }
<tr>
<th>author</th>
<td><?= $app->user->username ?></td>
</tr>
</table>
<?= include('form', $s->{form}, 'revoke this token') ?> 
? };
