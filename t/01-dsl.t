#!perl -T

use strict; use warnings;
use Test::More tests => 2;

BEGIN {
    use_ok( 'Shari::Conf' ) || print "Bail out!\n";
}

my $dsl = Shari::Conf->new;

isa_ok($dsl,'Shari::Conf');

my $config = $dsl->load_main_config({
      instance => 'einstein',
      config_file => './t/data/dsl.conf'
});

is($config->{'application_name'},'Developer Support Library');
is($config->{'namespace'},'DSL');

is($config->{'i18n'}->{'use'},'de');
is_deeply($config->{'i18n'}->{'language'},['DE','EN']);
