#-*- mode: perl;-*-

use Test::More tests => 40;

use_ok('Module::ParseDeps');

{
  ok(
    Module::ParseDeps::_search_directory('./t/data', 0) == 0,
    "Test non-recusive search"
  );
}

{
  my @files = Module::ParseDeps::_search_directory('./t/data', 1);
  ok(
    @files == 3,
    "Test recusive search"
  );

}

{
  my @files = Module::ParseDeps::_search_directory('./t/data/1', 1);
  ok(
    @files == 1,
    "Test recusive search"
  );

  ok( $files[0] =~ /Acme-CPAN-Distribution-Depends\.meta$/ );

  my $ref = Module::ParseDeps::_parse_meta( $files[0 ] );
  ok( ref($ref) eq 'HASH' );
  ok( (keys %$ref) == 6 );

  ok( $ref->{'Carp'} == 1 );
  ok( $ref->{'File::Spec'} == 2 );
  ok( $ref->{'Module::MakefilePL::Parse'} == 3 );
  ok( $ref->{'YAML'} == 4 );
  ok( $ref->{'perl'} eq '5.6.1' );
  ok( $ref->{'Test::More'} == 6 );
}

{
  my @files = Module::ParseDeps::_search_directory('./t/data/2', 1);
  ok(
    @files == 1,
    "Test recusive search"
  );

  ok( $files[0] =~ /META.yml$/ );

  my $ref = Module::ParseDeps::_parse_meta( $files[0 ] );
  ok( ref($ref) eq 'HASH' );
  ok( (keys %$ref) == 6 );

  ok( $ref->{'Carp'} == 1 );
  ok( $ref->{'File::Spec'} == 2 );
  ok( $ref->{'Module::MakefilePL::Parse'} == 3 );
  ok( $ref->{'YAML'} == 4 );
  ok( $ref->{'perl'} eq '5.6.1' );
  ok( $ref->{'Test::More'} == 6 );
}

{
  my @files = Module::ParseDeps::_search_directory('./t/data/3', 1);
  ok(
    @files == 1,
    "Test recusive search"
  );

  ok( $files[0] =~ /Makefile\.PL$/ );

  my $ref = Module::ParseDeps::_parse_makefile( $files[0 ] );
  ok( ref($ref) eq 'HASH' );
  ok( (keys %$ref) == 5 );

  ok( $ref->{'Carp'} == 1 );
  ok( $ref->{'File::Spec'} == 2 );
  ok( $ref->{'Module::MakefilePL::Parse'} == 3 );
  ok( $ref->{'YAML'} == 4 );
  ok( $ref->{'Test::More'} == 6 );
}

{
  my $ref = parsedeps('./t/data', 1);
  ok( ref($ref) eq 'HASH' );
  ok( (keys %$ref) == 6 );

  ok( $ref->{'Carp'} == 1 );
  ok( $ref->{'File::Spec'} == 2 );
  ok( $ref->{'Module::MakefilePL::Parse'} == 3 );
  ok( $ref->{'YAML'} == 4 );
  ok( $ref->{'perl'} eq '5.6.1' );
  ok( $ref->{'Test::More'} == 6 );
}
