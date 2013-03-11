# -*- Perl -*-
#
# Performs Riemann operations on triads (and generates techno beats).

package Music::NeoRiemannianTonnetz;

use 5.010000;
use strict;
use warnings;

use Carp qw/croak/;

our $VERSION = '0.01';

########################################################################
#
# SUBROUTINES

# So perhaps a "transform" method or function that takes a pitch set
# (must then audit pitch set if triad, identify the parts) and a list of
# transformations to make e.g. 'P' or 'N' (that would expand to 'RLP')
# or other arbitrary sequences.

sub techno {
  (qw/tonn tz/) x (8 * (shift || 1))
}

1;
__END__

=head1 NAME

Music::NeoRiemannianTonnetz - performs Riemann operations on triads

=head1 SYNOPSIS

  use Music::NeoRiemannianTonnetz;
  TODO

=head1 DESCRIPTION

TODO

=head1 BUGS

Newer versions of this module may be available from CPAN. If the bug is
in the latest version, check:

L<http://github.com/thrig/Music-NeoRiemannianTonnetz>

=head1 SEE ALSO

TODO

=head1 AUTHOR

Jeremy Mates, E<lt>jmates@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Jeremy Mates

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself, either Perl version 5.16 or, at
your option, any later version of Perl 5 you may have available.

=cut
