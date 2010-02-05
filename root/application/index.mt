? extends 'base';

? block content => sub {
<ul class="menu">
<li><a href="<?= $c->uri_for('application', 'create') ?>">get a new token</a></li>
</ul>
<ul>
? for my $app (@{$s->{apps}}) {
<li><a href="<?= $c->uri_for('application', $app->id) ?>"><?= $app->name ?></a>
? }
</ul>
? };
