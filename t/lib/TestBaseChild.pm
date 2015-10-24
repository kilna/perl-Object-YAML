package TestBaseChild;

use strict;
use warnings;

use Data::Dumper;

use TestBaseParent '-base';

TestBaseChild->test_param('test_value');

our @EXPORT = qw(export_test);
our @EXPORT_OK = qw(export_ok_test);

sub export_test { 'export_test' }
sub export_ok_test { 'export_ok_test' }

1;
