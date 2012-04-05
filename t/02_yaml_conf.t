
use strict;
use warnings;
use utf8;

use Test::More tests => 1;
use Test::Requires 'YAML','IO::String';

use Shari::Conf;

Shari::Conf->register_config_provider(
  'YAML' => sub {
     my ($self,$file) = @_;
     my $data = ref $file ? join('',<$file>) : $self->slurp_config_file($file);
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
    config_file => IO::String->new($main)
});

is($config->{'test'},'ok','instance configuration loaded');

#use Data::Dumper;
#print Dumper($config);

