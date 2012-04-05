
use strict;
use warnings;

use Test::More tests => 6;

use Shari::Conf;

my $config = Shari::Conf->load_main_config({
    instance => 'diode',
    config_file => './t/data/dsl.conf'
});

is($config->{'application_name'},'Developer Support Library','expected config data');
is($config->{'namespace'},'DSL','expected config data');

is($config->{'i18n'}->{'use'},'de','expected config data');
is_deeply($config->{'i18n'}->{'language'},['DE','EN'],'expected config data');

eval {
    $config = Shari::Conf->load_main_config({
        config_file => './t/data/dsl.conf'
    });
};

ok($@ =~ /No instance given/,'dies without instance argument');

eval {
    my $config = Shari::Conf->load_main_config({
        instance => 'diode'
    });
};

ok($@ =~ /No config file/,'dies without config file');


