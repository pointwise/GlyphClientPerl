#! /usr/bin/perl

#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

use IO::Socket::INET;
use Socket qw(IPPROTO_TCP TCP_NODELAY);

package Pointwise::GlyphClient;

sub new {
    my $class = shift;
    my $self = {
        _busy => 0,
        _auth_failed => 0
    };
    return bless $self, $class;
}

sub connect {
    my $self = shift;
    my %arg = @_;
    my $port = delete $arg{port} // $ENV{'PWI_GLYPH_SERVER_PORT'} // '2807';
    my $auth = delete $arg{auth} // $ENV{'PWI_GLYPH_SERVER_AUTH'} // '';
    my $host = delete $arg{host} // 'localhost';

    if (defined $self->{_socket}) {
        $self->{_socket}->close();
        undef $self->{_socket};
    }

    $self->{_busy} = 0;
    $self->{_auth_failed} = 0;

    $self->{_socket} = new IO::Socket::INET (
        PeerHost => $host,
        PeerPort => $port,
        Proto => 'tcp'
    );
    if (!defined $self->{_socket}) {
        return 0;
    }

    $self->{_socket}->setsockopt(IPPROTO_TCP, TCP_NODELAY, 1);

    $self->_send('AUTH', $auth);

    my ($type, $payload) = $self->_recv();
    if (!$type) {
        $self->{_socket}->close();
        undef $self->{_socket};
        return 0;
    }

    if ($type != 'READY') {
        $self->{_auth_failed} = ($type == 'AUTHFAIL');
        $self->{_busy} = ($type == 'BUSY');
        $self->{_socket}->close();
        undef $self->{_socket};
        return 0;
    }

    return 1;
}

sub is_busy {
    my ($self) = @_;
    return $self->{_busy};
}

sub auth_failed {
    my ($self) = @_;
    return $self->{_auth_failed};
}

sub eval {
    my ($self, $command) = @_;

    if (!$self->{_socket}) {
        die 'The client is not connected to a Glyph Server';
    }

    $self->_send('EVAL', $command);

    my ($type, $payload) = $self->_recv();
    if (!$type) {
        $self->{_socket}->close();
        undef $self->{_socket};
        die 'No response from the Glyph Server';
    }

    if ($type != 'OK') {
        die $payload;
    }

    return $payload;
}

sub close {
    my ($self) = @_;
    if ($self->{_socket}) {
        $self->{_socket}->close();
        undef $self->{_socket};
    }
}

sub _send {
    my ($self, $type, $payload) = @_;
    my $message_bytes = sprintf('%-8s%s', $type, $payload);
    my $message_length =  pack('N', length($message_bytes));

    $self->{_socket}->send($message_length);
    $self->{_socket}->send($message_bytes);
}

sub _recv {
    my ($self) = @_;
    my $message_length = $self->_recvall(4);
    $message_length = unpack('N', $message_length);
    if ($message_length == 0) {
        return ('', '');
    }

    my $message_bytes = $self->_recvall($message_length);
    if (length($message_bytes) < 8) {
        return ('', '');
    }

    my $type = substr($message_bytes, 0, 8);
    my $payload = substr($message_bytes, 8);
    return ($type, $payload);
}

sub _recvall {
    my ($self, $size) = @_;

    my $data = '';
    $self->{_socket}->recv($data, $size);
    return $data;    
}

1;

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
