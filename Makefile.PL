use inc::Module::Install;
name 'Mgrgw';
all_from 'lib/Mgrgw.pm';

requires 'Ark';

tests 't/*.t';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
