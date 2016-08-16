use 5.008001;
use strict;
use warnings;

package Dancer2::Session::Sereal;
our $AUTHORITY = 'cpan:YANICK';
# ABSTRACT: Dancer 2 session storage in files with Sereal
# VERSION
$Dancer2::Session::Sereal::VERSION = '0.002';
use Moo;
use Dancer2::Core::Types;
use Sereal::Encoder;
use Sereal::Decoder;

#--------------------------------------------------------------------------#
# Attributes
#--------------------------------------------------------------------------#

has _suffix => (
    is      => 'ro',
    isa     => Str,
    default => sub { ".srl" },
);

has _encoder => (
    is      => 'lazy',
    isa     => InstanceOf ['Sereal::Encoder'],
    handles => { '_freeze' => 'encode' },
);

sub _build__encoder {
    my ($self) = @_;
    return Sereal::Encoder->new(
        {
            snappy         => 1,
            croak_on_bless => 1,
        }
    );
}

has _decoder => (
    is      => 'lazy',
    isa     => InstanceOf ['Sereal::Decoder'],
    handles => { '_thaw' => 'decode' },
);

sub _build__decoder {
    my ($self) = @_;
    return Sereal::Decoder->new(
        {
            refuse_objects => 1,
            validate_utf8  => 1,
        }
    );
}

#--------------------------------------------------------------------------#
# Role composition
#--------------------------------------------------------------------------#

with 'Dancer2::Core::Role::SessionFactory::File';

sub _freeze_to_handle {
  my ($self, $fh, $data) = @_;
  binmode $fh;
  print {$fh} $self->_freeze($data);
  return;
}

sub _thaw_from_handle {
  my ($self, $fh) = @_;
  binmode($fh);
  return $self->_thaw( do { local $/; <$fh> } );
}

1;

=pod

=encoding UTF-8

=head1 NAME

Dancer2::Session::Sereal - Dancer 2 session storage in files with Sereal

=head1 VERSION

version 0.002

=head1 DESCRIPTION

This module implements Dancer 2 session engine based on L<Sereal> files.

This backend can be used in single-machine production environments, but two
things should be kept in mind: The content of the session files is not
encrypted or protected in anyway and old session files should be purged by a
CRON job.

=head1 CONFIGURATION

The setting B<session> should be set to C<Sereal> in order to use this session
engine in a Dancer2 application.

Files will be stored to the value of the setting C<session_dir>, whose default
value is C<appdir/sessions>.

Here is an example configuration that use this session engine and stores session
files in /tmp/dancer-sessions

    session: "Sereal"

    engines:
      session:
        Sereal:
          session_dir: "/tmp/dancer-sessions"

=head1 AUTHOR

David Golden <dagolden@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

__END__


# vim: ts=4 sts=4 sw=4 et:
