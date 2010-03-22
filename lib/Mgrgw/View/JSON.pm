package Mgrgw::View::JSON;
use Ark 'View::JSON';
use Data::Rmap;
use Text::MicroTemplate;

has '+expose_stash' => (
    default => 'json',
);

has '+json_dumper' => (
    default => sub {
        my $self = shift;
        sub {
            my (@args) = @_;
            rmap { $_ = Text::MicroTemplate::escape_html($_) } @args;
            $self->json_driver->encode(@args);
        };
    }
);

after process => sub {
    my ($self, $c) = @_;
    my $agent = $c->req->user_agent;
    if ($agent =~ /Safari/ && $agent !~ m{WebKit/4}) {
        (my $body = $c->res->body) =~ s/^\xEF\xBB\xBF//;
        $c->res->body($body);
    }
};

1;
