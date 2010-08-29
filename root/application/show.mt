? extends 'base';

? block content => sub {
<ul class="menu">
<li><a href="<?= $c->uri_for('application')  ?>">back to list</a></li>
<li><a href="<?= $c->uri_for('application',$s->{app}->id, 'edit')  ?>">edit this app</a></li>
</ul>
<table class="view">
? for my $attr (qw(name callback_url consumer_key consumer_secret)) {
<tr>
<th><?= $attr ?></th>
<td><?= $s->{app}->$attr || 'undefined' ?></td>
</tr>
? }
</table>
? };
