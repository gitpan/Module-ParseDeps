
exit (0); # make sure automated scripts don't try to run this

use ExtUtils::MakeMaker; 

WriteMakefile
(
    'NAME' => 'ACME::CPAN::Distribution::Depends',
    'PREREQ_PM' => {
         'Carp' => '1',
         'File::Spec' => '2',
         'Module::MakefilePL::Parse' => '3',
         'Test::More' => '6',
         'YAML' => '4'
       },
  )
;
