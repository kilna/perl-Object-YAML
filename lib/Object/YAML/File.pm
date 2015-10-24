package Object::YAML::File;

use strict;
use warnings;

use Object::YAML::Base {};

use YAML qw(LoadFile);
use Carp qw(croak);
use File::stat;
use Data::Dumper;

sub file_is_current {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return $class->file_mtime <= $class->file_last_loaded;
}

sub file_mtime {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return eval { stat($class->file)->mtime } || 0;
}

sub file {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return do { my $d = $class->root_dir; $d =~ s|/*$||; $d }.'/'.$class->filename;
}

sub filename {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return $class->class_plural.'.yml';
}

sub root_dir {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return "$FindBin::Bin/../config/"
}

sub all {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $stash = get_stash($class);
    my $objs = $stash->get_or_add_symbol('@objs');
    unless ($class->file_is_current && scalar @{$objs}) {
        $objs = [];
        my $count = 0;
        foreach my $item ( LoadFile( $class->file ) ) {
            my %info = %{$item};
            if ( $class->auto_id ) { $info{id} = ++$count; }
            my $obj = bless { %info }, $class;
            push @{$objs}, $obj;
        }
        if ($class->can('obj_cmp')) {
            # By default ->all returns the items in the order they appear
            # in the file.  If you want to order them otherwise, you need
            # a class method ->obj_cmp
           $objs = [ sort { $class->obj_cmp( $a, $b ) } @{$objs} ];
        }
        if ($class->can('load')) { $class->load( $objs ); }
        if ($class->has_id) {
            $stash->add_symbol( '@ids' => [ map { $_->id } @{$objs} ] );
        }
        $stash->add_symbol( '@objs' => $objs );
        $class->file_last_loaded( $class->file_mtime );
    }
    my $ref = $class->has_id
        ? { map { $_->id => $_ } @{$objs} }
        : $objs;
    return wantarray ? @{$objs} : $ref;
}

sub ids {
    my $class = ref($_[0]) ? ref(shift) : shift;
    die "Class $class does not have IDs" unless $class->has_id;
    my $stash = get_stash($class);
    $class->all();
    my $ids = $stash->get_or_add_symbol('@ids');
    return wantarray ? @{$ids} : $ids;
}

sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    die "Cannot call ".$class."->new when class does not have IDs"
        unless $class->has_id;
    my $id = shift @_;
    die "Unable to find $class '$id'... ".Dumper($class->all)
        unless exists $class->all->{$id};
    return $class->all->{$id};
}

1;

