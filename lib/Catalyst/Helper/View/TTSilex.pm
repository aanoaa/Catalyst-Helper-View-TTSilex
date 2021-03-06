package Catalyst::Helper::View::TTSilex;
# ABSTRACT: Helper for TT view which builds a skeleton 'Silex' ecrf web site

use strict;
use File::Spec;
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::ShareDir qw/dist_dir/;
use File::Slurp qw/slurp/;
use File::Find;

=head1 SYNOPSIS

    $ script/myapp_create.pl view Default TTSilex

=head1 DESCRIPTION

This helper module base on TTSite.
but custom aim to Silex ecrf.

=head1 METHODS

=head2 mk_compclass

Generates the component class.

=cut

sub mk_compclass {
    my ( $self, $helper, @args ) = @_;
    my $file = $helper->{file};
    $helper->render_file( 'compclass', $file );
    $self->mk_templates( $helper, @args );
    $self->mk_static( $helper, @args );
}

=head2 mk_comptest

Makes test for View.

=cut

sub mk_comptest {
    my ( $self, $helper ) = @_;
    my $test = $helper->{test};
    $helper->render_file( 'comptest', $test );
}

=head2 mk_templates

Generates the templates.

=cut

sub mk_templates {
    my ( $self, $helper ) = @_;
    my $base = $helper->{base};
    my $dist_dir = dist_dir('Catalyst-Helper-View-TTSilex');
    my $orig_dir = File::Spec->catfile( $dist_dir, 'root', 'templates', 'default' );
    my $template_dir = File::Spec->catfile( $base, 'root', 'templates' );
    my $target_dir = File::Spec->catfile( $base, 'root', 'templates', lc $helper->{name} );
    dircopy($orig_dir, $target_dir) or die $!;

    my @files;
    find({ wanted => sub {
        return if /^\.$/;
        open my $fh, '<', $_;
        return if -d $fh;
        push @files, File::Spec->rel2abs($_);
    } }, $target_dir);

    my $mode = 0644;
    chmod $mode, @files;

    my $template_conf = File::Spec->catfile( $dist_dir, 'myapp.conf' );
    my $conf = Catalyst::Utils::appprefix($helper->{app}) . '.conf.new';
    my $content = slurp $template_conf;
    my $vars = {
        lower_name => lc $helper->{name},
        name => $helper->{name}
    };

    $helper->render_file_contents($content, $conf, $vars);
}

=head2 mk_static

Copy files that required for require.js, coffeescript and sass

=cut

sub mk_static {
    my ( $self, $helper ) = @_;
    my $base = $helper->{base};
    my $dist_dir = dist_dir('Catalyst-Helper-View-TTSilex');
    my $orig_dir = File::Spec->catfile( $dist_dir, 'root', 'static' );
    my $target_dir = File::Spec->catfile( $base, 'root', 'static' );
    dircopy($orig_dir, $target_dir) or die $!;
    my $config_rb = File::Spec->catfile( $base, 'root', 'config.rb' );
    copy(File::Spec->catfile( $dist_dir, 'root', 'config.rb' ), $config_rb) or die $!;
    chmod 0644, $config_rb;

    my @files;
    find({ wanted => sub {
        return if /^\.$/;
        open my $fh, '<', $_;
        return if -d $fh;
        push @files, File::Spec->rel2abs($_);
    } }, $target_dir);

    my $mode = 0644;
    chmod $mode, @files;
}

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::View::TT>, L<Catalyst::Helper>,
L<Catalyst::Helper::View::TT>

=cut

1;

__DATA__

__compclass__
package [% class %];
# ABSTRACT: [% class %]

use strict;
use base 'Catalyst::View::TT';

=head1 SYNOPSIS

    sub action :Local {
        my ($self, $c) = @_;
        # stashed template name automatically like below
        # $c->stash->{template} = 'action.tt'
    }

=head1 DESCRIPTION

Catalyst TTSilex View aim to Silex ecrf web site.

=head1 SEE ALSO

L<Catalyst::Helper::View::TTSilex>

=cut

1;

__comptest__
#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok '[% app %]::TTSilex' }
