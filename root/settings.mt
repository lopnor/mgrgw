? extends 'base';

? block content => sub {
<ul class="menu">
    <li><a href="<?= $c->uri_for('/application') ?>">setup applications</a></ul>
</li>
<?= include('form', $s->{form}, 'save settings') ?>
? }
