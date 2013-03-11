#!perl

use strict;
use warnings;

use Test::More;    # plan is down at bottom

eval 'use Test::Differences';    # display convenience
my $deeply = $@ ? \&is_deeply : \&eq_or_diff;

BEGIN { use_ok('Music::NeoRiemannianTonnetz') }

my @techno           = (qw/tonn tz/) x 8;
my @even_more_techno = (qw/tonn tz/) x 32;

$deeply->( [Music::NeoRiemannianTonnetz::techno], \@techno, 'tonn tz' );
$deeply->(
  [ Music::NeoRiemannianTonnetz::techno(4) ],
  \@even_more_techno, 'even more tonn tz'
);

plan tests => 3;
