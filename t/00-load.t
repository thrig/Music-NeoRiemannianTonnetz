#!perl
use 5.010000;
use strict;
use warnings FATAL => 'all';
use Test::Most;

plan tests => 1;

BEGIN {
  use_ok('Music::NeoRiemannianTonnetz') || print "Bail out!\n";
}

diag(
  "Testing Music::NeoRiemannianTonnetz $Music::NeoRiemannianTonnetz::VERSION, Perl $], $^X"
);
