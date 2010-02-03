<html>
<head>
    <title><? block title => 'mgrgw.jp' ?></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" href="http://soffritto.org/css/style.css">
    <style type="text/css">
        h1 {
            color: #fcc800;
            font-size: 100%;
            float: left;
        }
        div.status {
            margin-top: 5px;
        }
        .username {
            color: #fcc800;
            margin-right: 5px;
        }
        .timestamp {
            color: #cccccc;
            font-size: 80%;
            margin-left: 5px;
        }
        ul.menu {
            text-align: right;
            margin: 0px; 
            padding: 0px;
        }
        ul.menu li{
            margin: 0px;
            display: inline;
        }
        form {
            margin: 10px;
        }
        input {
            margin-right: 5px;
        }
    </style>
? block js => '';
</head>
<body>
<div id="header">
? block header => sub {
    <h1><? block 'title' ?></h1>
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
