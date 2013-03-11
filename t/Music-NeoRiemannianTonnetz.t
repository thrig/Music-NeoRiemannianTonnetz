#!perl

use strict;
use warnings;

use Test::More;    # plan is down at bottom

eval 'use Test::Differences';    # display convenience
my $deeply = $@ ? \&is_deeply : \&eq_or_diff;

BEGIN { use_ok('Music::NeoRiemannianTonnetz') }

my $Nrt = Music::NeoRiemannianTonnetz->new;
isa_ok( $Nrt, 'Music::NeoRiemannianTonnetz' );

taskify_tokens();
techno();

sub taskify_tokens {
  my $tasks = $Nrt->taskify_tokens('P');
  is( scalar @$tasks, 1, 'single step task count' );
  ok( ref $tasks->[0] eq 'CODE', 'task is code ref' );

  $tasks = $Nrt->taskify_tokens('N');    # should expand to RLP
  is( scalar @$tasks, 3, 'three step task count' );
  is( scalar( grep { ref $_ eq 'CODE' ? 1 : () } @$tasks ),
    3, 'three little code refs' );
}

sub techno {
  my @techno           = (qw/tonn tz/) x 8;
  my @even_more_techno = (qw/tonn tz/) x 32;

  $deeply->( [ $Nrt->techno ],    \@techno,           'tonn tz' );
  $deeply->( [ $Nrt->techno(4) ], \@even_more_techno, 'even more tonn tz' );
}

plan tests => 8;
