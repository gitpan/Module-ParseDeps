use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Module::ParseDeps',
     license => 'perl',
     requires => {
       'perl'                       => '5.6.1',
       'Carp'                       => 0,
       'File::Spec'                 => 0,
       'Module::MakefilePL::Parse'  => 0.03,
       'YAML'                       => 0,
     },
     recommends => {
     },
     build_requires => {
       'Test::More'                 => 0,
     },
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>',
);

$build->create_build_script;
