package Object::YAML::Glob;

use strict;
use warnings;

use Object::YAML::Base '-base';

use YAML qw(LoadFile);
use Carp qw(croak);
use File::stat;
use Data::Dumper;

sub yaml_files {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return glob $class->glob; 
}

sub yaml_file {
    my $self = shift;
    return $self->{yaml_file}
}


1;

