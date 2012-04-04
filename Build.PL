use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Shari::Conf',
    license             => 'perl',
    dist_author         => q{Sebastian Knapp <sk@computer-leipzig.com>},
    dist_version_from   => 'lib/Shari/Conf.pm',
    build_requires => {
        'Test::More' => 0,
	'Module::Build' => '0.40',
        'Test::Requires' => 0,
        'IO::String' => 0
    },
    requires => {
        'perl' => 5.006,
	'Config::General' => 0,
	'Hash::Merge' => 0
    },
    add_to_cleanup      => [ 'Shari-Conf-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
