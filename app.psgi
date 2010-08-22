#!perl
use lib 'lib';
use Plack::Builder;
use Plack::Middleware::Static;
use Plack::Middleware::ReverseProxy;

use Mgrgw;

my $app = Mgrgw->new;
$app->setup;

builder {
    enable 'Plack::Middleware::ReverseProxy';
    enable 'Plack::Middleware::Static',
#        path => qr{^/(js/|css/|swf/|images?/|imgs?/|static/|[^/]+\.[^/]+$)},
        path => qr{^/(js/|css/|swf/|images?/|imgs?/|static/)},
        root => $app->path_to('root')->stringify;

    $app->handler;
};
