? extends 'base';

? block content => sub {
<ul class="menu">
<li><a href="<?= $c->uri_for('webhook')  ?>">back to list</a></li>
<li><a href="<?= $c->uri_for('webhook',$s->{item}->id, 'update')  ?>">edit</a></li>
<li><a href="<?= $c->uri_for('webhook',$s->{item}->id, 'delete')  ?>">delete</a></li>
</ul>
<table class="view">
? for my $attr (qw(uri type)) {
<tr>
<th><?= $attr ?></th>
<td><?= $s->{item}->$attr || 'undefined' ?></td>
</tr>
? }
</table>
? };

