? extends 'base';

? block content => sub {
<ul>
? for my $token ($c->user->obj->tokens({type => 'access token'})) {
? my $app = $token->application
    <li><a href="<?= $c->uri_for('/oauth', $token->id) ?>"><?= $app->name ?></a> by <?= $app->user->username ?></li>
? }
</ul>
? };
