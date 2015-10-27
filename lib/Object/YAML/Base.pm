package Object::YAML::Base;

use strict;
use warnings;

use Data::Dumper;
use Carp qw(croak);
require Exporter;
require Exporter::Heavy;

$|++;

my $pluralize = sub {
    my $noun   = default(shift);
    my $plural = default(shift); # Allow easy overiding by passing
                                 # in an explicit value
    if ($plural ne '')                      { return $plural;    }
    if ($noun =~ m/s$/)                     { return $noun.'es'; }
    elsif ($noun =~ m/^(.*?)o$/)            { return $1.'oes';   }
    elsif ($noun =~ m/^(.*?[^aeiouf])fe?$/) { return $1.'ves';   }
    elsif ($noun =~ m/^.*?[aeiou]y$/)       { return $noun.'s';  }
    elsif ($noun =~ m/^(.*?)y$/)            { return $1.'ies';   }
    return $noun . 's';
};

sub oy_pkg {
    my $pkg = shift;
    my %set = @_;
    no strict 'refs';
    no warnings 'uninitialized';
    unless (scalar keys %{$pkg.'::oy_pkg'}) { %{$pkg.'::oy_pkg'} = (); }
    $pkg_info = \%{$pkg.'::oy_pkg'};
    $pkg_info->{$_} = $set{$_} foreach keys %set;
    return $pkg_info;
}

sub oy_cache {
    my $pkg = shift;
    my $cache = $pkg->oy_pkg()->{cache} || [];
    $pkg->oy_pkg()->{cache} = $cache;
    return wantarray ? @$cache : $cache;
}

sub oy_index {
    my $pkg = shift;
    my $index = shift;
    my $index_h = $pkg->oy_pkg()->{indexes}{$index} || {};
    $pkg->oy_pkg()->{indexes}{$index} = $index_h;
    return wantarray ? %$index_h : $index_h;
}

sub oy_index_get {
}



sub import {

    my $pkg = shift;
    (caller 1)[3] =~ m/^(.*)::(\w+)$/
        or croak "Unable to parse caller function";
    my $caller_pkg = $1;
    my $caller_sub = $2;
    $caller_sub eq 'BEGIN'
        or croak "Must be called at import time";

    my $base = 0;
    my $pkg_info = $caller_pkg->oy_pkg();
    for ( my $i = 0; $i <= $#_; $i++ ) {
        if (ref($_[$i]) eq 'HASH' ) {
            oy_pkg( $caller_pkg, %{ splice @_, $i, 1 }  );
            $i--;
            $base = 1;
        }
        elsif ($_[$i] eq '-base') {
            splice @_, $i, 1;
            $i--;
            $base = 1;
        }
    }
    
    if ($base) {
        no strict 'refs';
        no warnings 'uninitialized';
        @{$caller_pkg.'::ISA'} = $pkg, grep { $_ ne $pkg } @{$caller_pkg.'::ISA'};
        *{$caller_pkg.'::import'} = *{$pkg.'::import'};
    }

    Exporter::Heavy::heavy_export( $pkg, $caller_pkg, @_ );
}

sub AUTOLOAD {
    my $subname = our $AUTOLOAD;
    $subname =~ s/^.*:://;
    my $context = shift; # a ref if called as a obj method, or a package name
    my $value = shift;
    if ( ref $context ) {
        if (defined $value) { $context->{$subname} = $value; }
        return eval { $context->{$subname} };
    }
    elsif ( $context =~ m/^(\w+|::)+$/ ) {
        my $p = $context->oy_pkg;
#print Dumper(\%pkg_info);
#print Dumper($p);
        if (defined $value) { $p->{$subname} = $value; }
        return $p->{$subname};
    }
    else {
        croak "Unknown subroutine $subname";
    }
}

1;

