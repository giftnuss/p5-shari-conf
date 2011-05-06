#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Shari::Conf' ) || print "Bail out!\n";
}

diag( "Testing Shari::Conf $Shari::Conf::VERSION, Perl $], $^X" );
