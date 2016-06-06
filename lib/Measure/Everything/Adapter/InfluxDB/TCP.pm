package Measure::Everything::Adapter::InfluxDB::TCP;
use strict;
use warnings;

our $VERSION = '1.000';

# ABSTRACT: Send stats to Influx via TCP using Telegraf

use base qw(Measure::Everything::Adapter::Base);
use InfluxDB::LineProtocol qw(data2line);
use IO::Socket::INET;

sub init {
    my $self = shift;

    my $socket = IO::Socket::INET->new(
        PeerAddr  => $config{host} || 'localhost',
        PeerPort  => $config{port} || 8094,
        Proto     => 'tcp',
    );
    $self->{socket} = $socket;
}

sub write {
    my $self = shift;
    my $line = data2line(@_);
    return $self->{socket}->send( $line );
}

1;
__END__

=head1 SYNOPSIS

    Measure::Everything::Adapter->set( 'InfluxDB::TCP',
        host => 'localhost',   # default
        port => 8094,          # default
    );

    use Measure::Everything qw($stats);
    $stats->write('metric', 1);


=head1 DESCRIPTION

Send stats via TCP to a
L<Telegraf|https://influxdata.com/time-series-platform/telegraf/>
service, which will forward them to L<InfluxDB|https://influxdb.com/>.
No buffering whatsoever, so there is one TCP request per call to
C<< $stats->write >>. This might be a bad idea.

If a request fails no further error handling is done. The metric will be lost.

=head3 OPTIONS

Set these options when setting your adapter via C<< Measure::Everything::Adapter->set >>

=over

=item * host

Name of the host where your Telegraf is running. Default to C<localhost>.

=item * port

Port your Telegraf is listening. Defaults to C<8094>.

=back

