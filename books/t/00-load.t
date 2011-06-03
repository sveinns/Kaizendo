#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Books' ) || print "Bail out!\n";
}

diag( "Testing Books $Books::VERSION, Perl $], $^X" );
