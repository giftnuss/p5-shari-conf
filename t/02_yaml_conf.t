
use strict;
use warnings;
use utf8;

use Test2::V0;
use Test::Requires 'YAML','Path::Tiny';

use Shari::Conf;
use Path::Tiny;

Shari::Conf->register_config_provider(
  'YAML' => sub {
     my ($self,$source,$type) = @_;
     my $data;
     if( !defined($type) || $type eq Shari::Conf->FILE ) {
         $data = Path::Tiny::path($self->get_config_dir)->child($source)->slurp();
     }
     elsif( $type eq Shari::Conf->TEXT ) {
         $data = $source;
     }
     $self->merge_config(YAML::Load($data));
});

my $main = <<__YAML__;
---
global:
   name: alternative
   position: north

   style:
       default: blur
       list: 
           - blur
           - clear

instance:
   diode:
       ConfigureVia: YAML yaml.conf
__YAML__

my $conf = Shari::Conf->new;
$conf->set_config_dir('./t/data');

my $config = $conf->load_main_config({
    provider => 'YAML',
    instance => 'diode',
    source => $main, type => Shari::Conf->TEXT
});

is($config->{'test'},'ok','instance configuration loaded');
is($config->{'style'}{'default'},'blur','global used');


done_testing();

#use Data::Dumper;
#print Dumper($config);

