use inc::Module::Install;

name     'Books';
all_from 'lib/Books.pm';
author   q{Sveinn Sandvik Svendsen <sveinn@kaizendo.org>};
license  'AGPLv3';

build_requires 'Test::More';

auto_install;

WriteAll;

