#!/usr/bin/perl

BEGIN {
    # because the opensim http server just accept old HTTP/1.0 protocol!!!
    $ENV{PERL_LWP_USE_HTTP_10} ||= 1;  # default to http/1.0
}

use RPC::XML::Client;

my $client = new RPC::XML::Client('http://localhost:8010');
my $req = RPC::XML::request->new(
            'admin_load_oar',
            {
                password => 'secret',
                region_name => 'Akisim',
				filename => '/Users/markusgasser/Documents/AkiGoogle Drive/akkisim/oar/akisim_1_prim.oar'
            }
);

my $res = $client->send_request($req);
my %val = %$res;
my $key;

foreach $key (keys %val) {
    print "$key --> ". $val{$key}->as_string ."\n";
}
