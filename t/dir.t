use warnings;
use strict;

use FindBin;
use lib $FindBin::Bin.'/../lib';
use lib $FindBin::Bin.'/lib';

use Test::More;

use_ok( 'TestDir' );

done_testing();
