<html>
<head>
    <title><? block title => 'mgrgw.jp' ?></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <style type="text/css">
        * {
            font-family: "Lucida Grande", Verdana, Arial, Geneva, sans-serif;
            line-height: 2em;
            font-weight: normal;
            margin: 0;
            padding: 0;
        }
        body {
            margin: 30px;
            padding: 30px;
            border: 2px solid #FCC800;
        }
        a {
            text-decoration: none;
            color: #FCC800;
            padding: 2px;
        }
        a:hover {
            border-bottom: 2px solid #fcc800;
        }
        dl, ul, p, dd {
            margin: 0px 30px;
        }
        h1 {
            color: #fcc800;
            font-size: 100%;
            float: left;
        }
        h1 a {
            background: none;
            height: 1em;
            text-indent: 0px;
        }
        div.status {
            margin-top: 5px;
        }
        .username {
            color: #fcc800;
            margin-right: 5px;
        }
        #appearance, .timestamp {
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
        form table {
            width: 100%;
        }
        input {
            padding-right: 5px;
        }
        th {
            color: #fcc800;
            text-align: right;
            padding-right: 5px;
        }
    </style>
? block js => '';
</head>
<body>
<div id="header">
? block header => sub {
    <h1><a href="<?= $c->uri_for('/') ?>"><? block 'title' ?></a></h1>
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
