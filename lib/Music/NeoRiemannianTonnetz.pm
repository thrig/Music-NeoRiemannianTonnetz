# -*- Perl -*-
#
# Performs Neo-Riemann operations on triads:
# https://en.wikipedia.org/wiki/Neo-Riemannian_theory

package Music::NeoRiemannianTonnetz;

use 5.010000;
use strict;
use warnings;

use Carp qw/croak/;
use List::Util qw/min/;
use Music::AtonalUtil ();
use Scalar::Util qw/reftype/;
use Try::Tiny;

our $VERSION = '0.10';

# for transform table, 'x'. "SEE ALSO" section in docs has links for [refs]
my %TRANSFORMATIONS = (
  P => \&_x_parallel,          # Parallel [WP]
  R => \&_x_relative,          # Relative [WP]
  L => \&_x_leittonwechsel,    # Leittonwechsel [WP]
  N => 'RLP',                  # Nebenverwandt [WP]
  S => 'LPR',                  # Slide [WP]
  H => 'LPL',                  # [WP]
  D => 'LR',                   # Dominant [Cohn 1998]
);

########################################################################
#
# SUBROUTINES

# _x_* are internal routines that handle the details of how the normal
# form of a particular pitch set (along with a hash reference containing
# the normal form pitchs to array refs of the original pitches, e.g. the
# results of a Music::AtonalUtil normal_form call) can be identified and
# the appropriate tweaks applied to the original pitches for the NRT
# operation in question. Return value is a pitch set (an array reference
# of pitch numbers).
#
# Probably better ways, but this is a first implementation for me...

sub _x_parallel {              # P
  my ( $pset, $pset2orig ) = @_;
  my @new_set;

  ...;

  @new_set = sort { $a <=> $b } @new_set;
  return \@new_set;
}

sub _x_relative {              # R
  my ( $pset, $pset2orig ) = @_;
  my @new_set;

  # XXX better way than strcmp to see if members of array exactly match?
  local $" = '';
  if ( "@$pset" eq '037' ) {
    for my $i ( keys %$pset2orig ) {
      if ( $i == 3 ) {
        push @new_set, map { $_ + 1 } @{ $pset2orig->{$i} };
      } else {
        push @new_set, @{ $pset2orig->{$i} };
      }
    }
  } elsif ( "@$pset" eq '047' ) {
    for my $i ( keys %$pset2orig ) {
      if ( $i == 4 ) {
        push @new_set, map { $_ - 1 } @{ $pset2orig->{$i} };
      } else {
        push @new_set, @{ $pset2orig->{$i} };
      }
    }
  } else {
    # XXX call "handle unknown" sub or bail or passthrough, depending
    ...;
  }

  @new_set = sort { $a <=> $b } @new_set;
  return \@new_set;
}

sub _x_leittonwechsel {    # L
  my ( $pset, $pset2orig ) = @_;
  my @new_set;

  ...;

  @new_set = sort { $a <=> $b } @new_set;
  return \@new_set;
}

# used as fall-through if set if find something do not know what to do
# with in transform table
sub get_default_token {
  my ($self) = @_;
  if ( !exists $self->{default_token} ) {
    croak 'default_token has not been set';
  }
  return $self->{default_token};
}

# Transform table, 'x'
sub get_x_table {
  my ($self) = @_;
  return $self->{x};
}

sub new {
  my ( $class, %param ) = @_;
  my $self = { x => \%TRANSFORMATIONS };

  # atonal normal_form used to classify chords and thus what rules to apply
  $self->{_atu} =
    exists $param{atu}
    ? $param{atu}
    : Music::AtonalUtil->new;

  if ( exists $param{x} ) {
    croak 'x must be hash reference' unless ref $param{x} eq 'HASH';
    $self->{x} = $param{x};
  }

  if ( exists $param{default_token} ) {
    $self->{default_token} = $param{default_token};
  }

  bless $self, $class;

  return $self;
}

sub set_default_token {
  my ( $self, $token ) = @_;
  if ( !defined $token ) {
    delete $self->{default_token};
  } else {
    $self->{default_token} = $token;
  }
  return $self;
}

sub set_x_table {
  my ( $self, $table ) = @_;
  croak 'transformation table must be hash reference'
    unless ref $table eq 'HASH';
  $self->{x} = $table;
  return $self;
}

# Turns string of tokens (e.g. 'RLP') into a list of tasks (CODE refs,
# or more strings, which are recursed on until CODE refs or error).
# Returns array reference of such tasks. Called by transform() if user
# has not already done this and passes transform() a string of tokens.
sub taskify_tokens {
  my ( $self, $tokens, $tasks ) = @_;
  $tasks //= [];
  $tokens = [ $tokens =~ m/([A-Z][a-z0-9]*)/g ] if !defined reftype $tokens;

  # XXX optimize input? - runs of R can be reduced, as those just toggle
  # the third - even number of R a no-op, odd number of R can be
  # replaced with 'R'. Other optimizations are likely possible.

  for my $t (@$tokens) {
    if ( exists $self->{x}{$t} ) {
      if ( ref $self->{x}{$t} eq 'CODE' ) {
        push @$tasks, $self->{x}{$t};
      } elsif ( !defined reftype $self->{x}{$t}
        or ref $self->{x}{$t} eq 'ARRAY' ) {
        $self->taskify_tokens( $self->{x}{$t}, $tasks );
      } else {
        croak 'unknown token in transformation table';
      }
    } else {
      if ( exists $self->{default_token} ) {
        if (!defined reftype $self->{default_token}
          or ref $self->{default_token} eq 'ARRAY' ) {
          $self->taskify_tokens( $self->{default_token}, $tasks );
        } elsif ( ref $self->{default_token} eq 'CODE' ) {
          push @$tasks, $self->{default_token};
        } else {
          croak 'unknown default_token';
        }
      } else {
        croak "unimplemented transformation token '$t'";
      }
    }
  }

  # TODO include the name of the operation in the list, so that is
  # available? would need return list of hash refs or something
  return $tasks;
}

sub techno { shift; (qw/tonn tz/) x ( 8 * ( shift || 1 ) ) }

sub transform {
  my $self   = shift;
  my $tokens = shift;
  croak 'tokens must be defined' unless defined $tokens;
  my $pset = ref $_[0] eq 'ARRAY' ? $_[0] : [@_];
  croak 'pitch set must contain something' if !@$pset;

  # Assume list of tasks (code refs to call) if array ref, otherwise try
  # to generate such a list.
  my $tasks;
  if ( ref $tokens eq 'ARRAY' ) {
    $tasks = $tokens;
  } else {
    try { $tasks = $self->taskify_tokens($tokens) } catch { croak $_ };
  }

  my $new_pset = [@$pset];
  for my $task (@$tasks) {
    try { $new_pset = $task->( $self->{_atu}->normal_form($new_pset) ); }
    catch {
      # XXX or have callback or ignore or whatever
      croak "could not apply task: $_";
    }
  }

  return $new_pset;
}

1;
__END__

=head1 NAME

Music::NeoRiemannianTonnetz - performs Riemann operations on triads

=head1 SYNOPSIS

  use Music::NeoRiemannianTonnetz;
  my $nrt = Music::NeoRiemannianTonnetz->new;

  # "relative" changes Major to minor
  $nrt->transform('R', [60, 64, 67]);   # [60, 63, 67]

  my $tasks = $nrt->taskify_tokens('LPR');
  my $new_pitch_set = $nrt->transform($tasks, [0,3,7]);

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

=over 4

=item *

[WP] https://en.wikipedia.org/wiki/Neo-Riemannian_theory as an
introduction.

=item *

[Cohn 1998] "Introduction to Neo-Riemannian Theory: A Survey and a
Historical Perspective" by Richard Cohn. Journal of Music Theory, Vol.
42, No. 2, Neo-Riemannian Theory (Autumn, 1998), pp. 167-180.

See also the entire Journal of Music Theory Vol. 42, No. 2, Autumn, 1998
publication: L<http://www.jstor.org/stable/i235025>

=item *

Various other music modules by the author, for different views on music
theory: L<Music::AtonalUtil>, L<Music::Canon>,
L<Music::Chord::Positions>, among others.

=back

=head1 AUTHOR

Jeremy Mates, E<lt>jmates@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Jeremy Mates

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself, either Perl version 5.16 or, at
your option, any later version of Perl 5 you may have available.

=cut
