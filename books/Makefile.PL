use inc::Module::Install;

name     'Books';
all_from 'lib/Books.pm';
author   q{Sveinn Sandvik Svendsen <sveinn@kaizendo.org>};
license  'AGPLv3';
abstract 'This package contains book(s) in stripped (partial) HTML and methods for stripping them. The goal is that the books can be used by App::Kaizendo.';


build_requires 'Test::More';

auto_install;

WriteAll;

