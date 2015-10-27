package Object::YAML::Glob;

use strict;
use warnings;

use Object::YAML::Base '-base';

use YAML qw(LoadFile);
use Carp qw(croak);
use File::stat;
use Data::Dumper;

sub oy_files {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return glob $class->glob; 
}

sub oy_file {
    my $self = shift;
    return $self->{_oy_file}
}

sub oy_cache {
}

sub oy_file_mtime {
}

sub oy_cache_mtime {
}

sub oy_file_exists {
}

sub oy_file_is_current {
}

sub oy_glob_wildcards {
}

sub oy_glob {
}

sub all {
}

sub new {
}

1;

