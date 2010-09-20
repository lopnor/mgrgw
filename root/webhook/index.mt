? extends 'base';

? block content => sub {
<ul class="menu">
<li><a href="<?= $c->uri_for('webhook', 'create') ?>">create new webhook</a></li>
</ul>
<ul>
? for my $hook (@{$s->{list}}) {
<li><a href="<?= $c->uri_for('webhook', $hook->id) ?>"><?= $hook->uri ?></a>
? }
</ul>
? };
