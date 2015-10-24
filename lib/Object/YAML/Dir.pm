package Object::YAML::Dir;

use strict;
use warnings;

use Object::YAML::Base '-base';

use YAML qw(LoadFile);
use Carp qw(croak);
use File::stat;
use Data::Dumper;

sub dir_is_current {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return $class->dir_mtime <= $class->dir_last_loaded;
}

sub dir_mtime {
    my $class = ref($_[0]) ? ref(shift) : shift;
    return stat($class->dir)->mtime;
}

sub all {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $stash = get_stash($class);
    my $objs = $stash->get_or_add_symbol('%objs');
    unless ( $class->dir_is_current && scalar keys %{$objs} ) {
        opendir( my $dirh, $class->dir )
            || die "Unable to open dir ".$class->dir;
        my @ids = ();
        while ( my $entry = readdir $dirh ) {
            next if $entry =~ m/^[._]/;
            next unless $entry =~ s/.yml$//;
            push @ids, $entry;
        }
        closedir $dirh;
        $objs = { map { $_ => $class->new($_) } @ids };
        if ( $class->can('obj_cmp') ) {
            @ids = map { $_->id }
                sort { $class->obj_cmp( $a, $b ) }
                values %{$objs};
        }
        $stash->add_symbol('@ids', \@ids);
        $stash->add_symbol('%objs' => $objs);
        $class->dir_last_loaded( $class->dir_mtime );
    }
    return wantarray
        ? ( map { $objs->{$_} } $class->ids )
        : $objs;
}

sub ids {
    my $class = ref($_[0]) ? ref(shift) : shift;
    $class->all;
    my $stash = get_stash($class);
    my @ids = @{$stash->get_or_add_symbol('@ids')};
    return wantarray ? @ids : \@ids;
}

sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $stash = get_stash($class);
    my $id = shift;
    my $objs = $stash->get_or_add_symbol('%objs');
    my $self = $objs->{$id};
    unless ( eval { $self->file_exists && $self->file_is_current } ) {
#        print STDERR "File for $class $id wasn't current, loading file ".$class->file($id)."\n";
        my $yml = [{}];
        if ($self->file_exists) {
            $yml = eval { LoadFile( $class->file($id) ) };
            if ($@) { print STDERR "ERROR: $@\n" }
        }
#        print STDERR "YML for $class $id: " . Dumper($yml);
        $self = bless { %{$yml->[0]}, 'id' => $id }, $class;
        if ($self->can('load')) { $self->load(); }
        $self->_file_last_loaded( $self->file_mtime );
#        print STDERR "Obj for $class $id: " . Dumper($self);
        $objs->{$id} = $self;
        $stash->add_symbol('%objs', $objs);
    }
    else {
#        print STDERR "File for $class $id was already current\n";
    }
    return $self;
}

sub file_exists {
    my $self = shift;
    return -e $self->file;
}

sub file_is_current {
    my $self = shift;
    return $self->file_mtime <= $self->_file_last_loaded;
}

sub file_mtime {
    my $self = shift;
    return stat($self->file)->mtime;
}

sub file {
    my ($class, $id);
    if (ref $_[0]) { $class = ref($_[0]); $id = $_[0]->{id}; } # Obj method
    else { $class = shift; $id = shift; } # Class method
    return $class->dir."/$id.yml";
}

sub _file_last_loaded { return SUPER::_file_last_loaded(@_) || 0 }

1;

