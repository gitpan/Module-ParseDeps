package Module::ParseDeps;

use 5.006001;
use strict;
use warnings;

use Carp;
use File::Spec;
use Module::MakefilePL::Parse 0.03;
use YAML 'Load';

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw( parsedeps );
our %EXPORT_TAGS = ( 'all' => [ @EXPORT ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );


our $VERSION = '0.01';

sub _parse_meta {
  my $file = shift;

  unless (-r $file) {
    croak "Unable to read file: ", $file;
  }
  open my $fh, $file
    or croak "Unable to open file: ", $file;
  my $meta_file = join("", <$fh>);
  close $fh;

  unless ($meta_file) {
    croak "No data was read: ", $file;
  }
  unless ($meta_file =~ /^--- \#YAML:1\.0/) {
    $meta_file = "--- #YAML:1.0\n" . $meta_file;
  }

  my $meta;

    ($meta) = Load( $meta_file );

  if ($meta) {
    return { (%{$meta->{requires}||{ }}, %{$meta->{build_requires}||{ }}) };
  }
  else {
    return;
  }
}

sub _parse_makefile {
  my $file = shift;

  unless (-r $file) {
    croak "Unable to read file: ", $file;
  }

  open my $fh, $file
    or croak "Unable to open file: ", $file;
  my $makefile = join("", <$fh>);
  close $fh;

  unless ($makefile) {
    croak "No data was read: ", $file;
  }

  my $parse;
  eval {
    $parse = new Module::MakefilePL::Parse( $makefile );
  };

  unless ($parse) {
    return;
  }
  return { %{ $parse->required || { } } };
}

sub _search_directory {
  my $root_dir  = shift;
  my $recurse   = shift;

  unless (-d $root_dir) {
    croak $root_dir, " is not a directory";
  }

  opendir my $dh, $root_dir
    or croak "unable to open directory ", $root_dir;

  my @directory  = map { File::Spec->catfile($root_dir, $_) }
    grep /^[^.]+/, readdir $dh;
  
  closedir $dh;

  my @file_list   = grep /(Makefile\.PL|\.meta|META\.yml)$/, @directory;

  if ($recurse) {
    my @subdir_list = grep -d $_, @directory;
    foreach my $subdir (@subdir_list) {
      push @file_list, _search_directory($subdir, $recurse);
    }
  }

  return @file_list;
}


sub parsedeps {
  my $root_dir  = shift;
  my $recurse   = shift || 0;

  my @file_list = _search_directory($root_dir, $recurse);

  if (@file_list) {
    my @reqs = ( );
    while (my $file = shift @file_list) {
      if ($file =~ /(META\.yml|\.meta)$/) {
	push @reqs, %{ _parse_meta($file)     || { } };
      }
      elsif ($file =~ /Makefile\.PL$/) {
	push @reqs, %{ _parse_makefile($file) || { } };
      }
      else {
	croak "Don\'t know how to handle file", $file;
      }
    }
    if (@reqs) {
      return { @reqs };
    }
    else {
      return;
    }
  }
  else {
    return;
  }
}

1;
__END__

=head1 NAME

Module::ParseDeps - parse module dependencies from CPAN distribution

=head1 SYNOPSIS

  use Module::ParseDeps;

  $hashref = parsedeps('./Some-Module-Extracted-0.0/');

=head1 DESCRIPTION

This module will scan a directory containing an extracted CPAN
distribution for meta files (F<*.meta> or F<META.yml>) or
F<Makefile.PL> and parse those to determine which modules that
distribution claims to require.

It assumes that the distribution accurately notes required modules.

=head2 Functions

=over

=item parsedeps

  $hashref = parsedeps( $directory, $recurse );

Given a directory which contains an extracted CPAN distribution, it
C<parsedeps> searches for meta files or F<Makefile.PL> and returns a
hash reference of their required modules, where the keys are the
modules and the values are the version numbers.

If multiple F<Makefile.PL> files are present, they are merged.

=back

=head1 SEE ALSO

These other modules will also provide meta-information about CPAN
distributions:

  Module::CoreList
  Module::Info
  Module::Dependency
  Module::Depends
  Module::MakefilePL::Parse
  Module::PrintUsed
  Module::ScanDeps

=head1 AUTHOR

Robert Rothenberg <rrwo at cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Robert Rothenbeg.  All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
