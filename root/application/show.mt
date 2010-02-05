? extends 'base';

? block content => sub {
<table class="view">
? for my $attr (qw(name callback_url consumer_key consumer_secret)) {
<tr>
<th><?= $attr ?></th>
<td><?= $s->{app}->$attr || 'undefined' ?></td>
</tr>
? }
</table>
? };
