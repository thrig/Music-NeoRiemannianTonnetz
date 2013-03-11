# -*- Perl -*-
#
# Performs Riemann operations on triads (and generates techno beats).

package Music::NeoRiemannianTonnetz;

use 5.010000;
use strict;
use warnings;

use Carp qw/croak/;
use Scalar::Util qw/reftype/;

our $VERSION = '0.10';

my %TRANSFORMATIONS = (
  'P' => sub { ... },
  'R' => sub { ... },
  'L' => sub { ... },
  'N' => 'RLP', # Nebenverwandt
  'S' => 'LPR',    # Slide
  'H' => 'LPL',
);

########################################################################
#
# SUBROUTINES

sub new {
  my ( $class, %param ) = @_;
  # TODO need "default handler" if lookup something in x that does not
  # exist - throw exception, omit, sub for some named symbol
  my $self = { x => \%TRANSFORMATIONS };

  # XXX or also code ref for key/value lookup, if table gets too big
  if ( exists $param{x} ) {
    croak 'x must be hash reference' unless ref $param{x} eq 'HASH';
    $self->{x} = $param{x};
  }

  bless $self, $class;

  return $self;
}

# Turns string of tokens (e.g. 'RLP') into a list of tasks. Returns
# array reference of such tasks.
sub taskify_tokens {
  my ( $self, $tokens, $tasks ) = @_;
  $tasks //= [];
  $tokens = [ split '', $tokens ] if !defined reftype $tokens;

  for my $t (@$tokens) {
    if ( exists $self->{x}{$t} ) {
      if ( ref $self->{x}{$t} eq 'CODE' ) {
        push @$tasks, $self->{x}{$t};
      } else {
        $self->taskify_tokens( $self->{x}{$t}, $tasks );
      }
    } else {
      # XXX this could instead be a default handler
      croak "unimplemented transformation token '$t'";
    }
  }

  return $tasks;
}

sub techno { shift; (qw/tonn tz/) x ( 8 * ( shift || 1 ) ) }

sub transform {
  my $self = shift;
  croak 'need tokens and pitch set' if @_ < 2;
  my $tokens = shift;
  croak 'tokens must be defined' unless defined $tokens;

  # Assume list of tasks (code refs to call) if array ref, otherwise try
  # to generate such a list.
  my $tasks;
  if ( ref $tokens eq 'ARRAY' ) {
    $tasks = $tokens;
  } else {
    eval { $tasks = $self->taskify_tokens($tokens) };
    croak $@ if $@;
  }

  # TODO find root, third, fifth of the supplied pitch set (pass through
  # anything else, so cluster chord lacking third or fifth might be a
  # noop, regardless the tasks).

  my $new_pset;

  # TODO apply tasks

  return $new_pset;
}

1;
__END__

=head1 NAME

Music::NeoRiemannianTonnetz - performs Riemann operations on triads

=head1 SYNOPSIS

  use Music::NeoRiemannianTonnetz;
  my $nrt = Music::NeoRiemannianTonnetz->new;

  my $new_pitch_set = $nrt->transform('RLPP', [0, 4, 7]);

  my $tasks = $nrt->taskify_tokens('LPR');
  my $new_pitch_set = $nrt->transform($tasks, [0, 4, 7]);

=head1 DESCRIPTION

TODO

=head1 METHODS

TODO

=head1 BUGS

Newer versions of this module may be available from CPAN. If the bug is
in the latest version, check:

L<http://github.com/thrig/Music-NeoRiemannianTonnetz>

C<techno> is not a bug, though may bug some.

=head1 SEE ALSO

Various other music modules by the author, for different views on music
theory: L<Music::AtonalUtil>, L<Music::Canon>,
L<Music::Chord::Positions>, and more.

=head1 AUTHOR

Jeremy Mates, E<lt>jmates@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Jeremy Mates

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself, either Perl version 5.16 or, at
your option, any later version of Perl 5 you may have available.

=cut
