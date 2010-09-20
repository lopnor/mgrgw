? extends 'base';
? block content => sub {
<ul class="menu">
<li><a href="<?= $c->uri_for('webhook')  ?>">back to list</a></li>
</ul>
<?= include('form', $s->{form}, 'edit this webhook') ?>
? }


