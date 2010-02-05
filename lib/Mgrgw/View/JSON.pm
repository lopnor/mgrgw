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

1;
