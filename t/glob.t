use warnings;
use strict;

use FindBin;
use lib $FindBin::Bin.'/../lib';
use lib $FindBin::Bin.'/lib';

use Test::More;

use_ok( 'TestGlob' );

print "$_\n" foreach TestGlob->oy_files;

done_testing();

