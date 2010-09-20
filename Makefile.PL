use inc::Module::Install;
name 'Mgrgw';
all_from 'lib/Mgrgw.pm';

requires 'Ark';
requires 'DBIx::Class::TimeStamp';
requires 'DBIx::Class::EncodedColumn';
requires 'DateTime';
requires 'Data::Rmap';
requires 'Digest::SHA1';
requires 'Text::MicroTemplate';
requires 'Plack::Middleware::ReverseProxy';
requires 'Net::OAuth';
requires 'Cache::FastMmap';
requires 'JSON::Any';
requires 'JSON::XS';
requires 'XML::Simple';

# for mgrgw-im
requires 'AnyEvent::XMPP';
requires 'Config::Pit';
requires 'Net::Twitter';
requires 'DBI';
requires 'DBD::SQLite';
requires 'Net::SSLeay';

tests 't/*.t';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
