package Mgrgw::View::MT;
use Ark 'View::MT';

after process => sub {
    my ($self, $c) = @_;
    $c->res->content_type('text/html; charset=utf-8');
};

1;
