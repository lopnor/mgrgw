<html>
<head>
    <title><? block title => 'something like twitter' ?></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" href="http://soffritto.org/css/style.css">
    <style type="text/css">
        
        div.status {
            margin-top: 5px;
            padding: 5px;
        }
        .username {
            color: #fcc800;
            margin: 5px;
        }
        .timestamp {
            color: #cccccc;
            font-size: 80%;
            margin: 5px;
        }
        ul.menu {
            margin: 0px; 
            padding: 5px;
        }
        ul.menu li{
            margin: 0px;
            display: inline;
        }
    </style>
? block js => '';
</head>
<body>
<div id="header">
? block header => sub {
<ul class="menu">
? if (my $user = $c->user) {
    <li>hello, <?= $user->obj ? $user->obj->username : 'new user' ?>!</li>
    <li><a href="<?= $c->uri_for('/settings') ?>">settings</a></li>
    <li><a href="<?= $c->uri_for('/logout') ?>">logout</a></li>
? } else {
    <li>hello, guiest!</li>
    <li><a href="<?= $c->uri_for('/login') ?>">login</a></li>
? }
</ul>
? };
</div>
<div id="content">
? block content => '';
</div>
</body>
</html>
