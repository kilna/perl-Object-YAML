use warnings;
use strict;

use FindBin;
use lib $FindBin::Bin.'/../lib';
use lib $FindBin::Bin.'/lib';

use Test::More;

use_ok('TestBaseChild', ':DEFAULT', 'export_ok_test');

is( TestBaseChild->test_param(), 'test_value', 'Class parameter was set' );
is( export_test(), 'export_test', 'Subclassing Exporter worked for EXPORT' );
is( export_ok_test(), 'export_ok_test', 'Subclassing Exporter worked for EXPORT_OK' );

done_testing();
