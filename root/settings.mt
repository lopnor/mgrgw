? extends 'base';

? block content => sub {
<ul class="menu">
    <li><a href="<?= $c->uri_for('/application') ?>">apps</a></li>
    <li><a href="<?= $c->uri_for('/oauth') ?>">tokens</a></li>
</li>
<?= include('form', $s->{form}, 'save settings') ?>
? };
