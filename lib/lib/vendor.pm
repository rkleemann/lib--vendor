package lib::vendor;


use strict;

use Cwd         ();
use FindBin     ();
use File::Spec  ();

# File layout could be:
# .
# +- bin
# +- lib
# +- vendor
# +- ...
#
# Or:
#
# .
# +- lib
# +- vendor
# +- ...

our $APPDIR;
BEGIN {
    ( $APPDIR = $FindBin::RealBin ) =~ s!/bin$!! unless $APPDIR;
}

sub import {
    my ( $package, @vendors ) = @_;

    for my $vendor (@vendors) {
        $vendor = Cwd::abs_path(
            File::Spec->catdir( $APPDIR, "vendor/$vendor/lib" )
        );
    }
    unshift @vendors,
        Cwd::abs_path( File::Spec->catdir( $APPDIR, "lib" ) );

    shrink_INC(@vendors);
}

sub shrink_INC {
    my %seen = ();
    @INC = grep {
        my $key;
        if ( ref($_) ) {
            # If it's a ref, key on the memory address.
            $key = int $_;
        } elsif ( my ($dev, $inode) = stat($_) ) {
            # If it's on the filesystem, key on the combo of dev and inode.
            $key = join( _ => $dev, $inode );
        } else {
            # Otherwise, key on the element.
            $key = $_;
        }
        $key && !$seen{$key}++;
    } @_, @INC;
}

1;

__END__

=head1 NAME

lib::vendor - add vendor libraries to the module search path

=head1 SYNOPSIS

  # Include only $FindBin::RealBin/../lib in module search path.
  use lib::vendor;

or

  # Include in module search path:
  # $FindBin::RealBin/../lib,
  # $FindBin::RealBin/../vendor/core/lib 
  use lib::vendor qw(core);

or

  # Include in module search path:
  # $FindBin::RealBin/../lib,
  # $FindBin::RealBin/../vendor/core/lib,
  # $FindBin::RealBin/../vendor/common/lib,
  # $FindBin::RealBin/../vendor/mongodb/lib,
  # $FindBin::RealBin/../vendor/rabbitmq/lib
  use lib::vendor qw(core common mongodb rabbitmq);

or

  # Do nothing
  use lib::vendor ();

=head1 DESCRIPTION

Locates the full path to the script home and adds its lib directory to the
library search path, plus any vendor library directories specified.

=head1 AUTHOR

Bob Kleemann

=head1 SEE ALSO

L<lib>, L<mylib>, L<FindBin>

=cut

