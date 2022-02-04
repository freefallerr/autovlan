#!/usr/bin/env perl
# ABSTRACT: Tooling to automate adding vlan interfaces
# PODNAME: autovlan

use strict;
use warnings;
use feature 'say';

use IPC::System::Simple qw(system);
use Getopt::Long qw(GetOptions);
use Pod::Usage;

my( $opt_help, $opt_man, $opt_add, $opt_del, $opt_device, $opt_vid, $opt_addr, );

GetOptions(
	'h|?|help!' 	=> 	\$opt_help,
	'man!'		=>	\$opt_man,
	'a|add!'	=>	\$opt_add,
	'd|delete|remove!'	=>	\$opt_del,
	'i|interface=s'	=>	\$opt_device,
	'V|vid=s'	=>	\$opt_vid,
	'L|address=s'	=>	\$opt_addr
) or pod2usage( "Try '$0 --help' for more information." );

pod2usage( -verbose => 1 ) if $opt_help;
pod2usage( -verbose => 2 ) if $opt_man;

=head1 NAME 

autovlan - Makes configuring vlan interfaces simpler

=head1 SYNOPSIS

autovlan [-a add/-d delete] [-i interface] [-V vid] [-L address]

=head1 DESCRIPTION

Autovlan is a script which allows for a user to configure vlan specific interfaces easily, it encapsulates setting up the correct modules and the creation and configuration of a new child interface which tag all packets using that interface with the specified vlan ID.

The following options are as follows.

=over 8

=item -a/--add

Will create a child interface with the specified interface, vid and address if passed in. 

=item -d/--delete

Deletes a child interface with the specified interface and vid. 

=item -i/--interface

The specified parent interface of the vlan interface.

=item -V/--vid

The vid which you want the interface to tag all traffice for.

=item -L/--address

If you know what address you want for that child interace specify it here. 

=back

=cut

if ($opt_add && $opt_del) {
	say STDERR "[!] Both 'add' and 'delete' were detected. There should be only one";
	pod2usage( -verbose => 1 );
	exit;
}

if (not defined $opt_device){
	say STDERR "[!] No 'interface' detected, exiting";
	pod2usage( -verbose => 1 );
	exit;
}

if (not defined $opt_vid){
	say STDERR "[!] No 'VID' detected, exiting";
	pod2usage( -verbose => 1 );
	exit;
}

my $mod_check = system( "modinfo 8021q > /dev/null 2>&1" );
if ($mod_check) {
	say "[+] Loading required kernel module as it is missing";
	system( "modprobe 8021q");
}

if ($opt_add) {
	say "[+] Adding child interface $opt_device with vlan id $opt_vid";
	# Add vlan interface as child of given interface
	system( "ip link add link $opt_device name $opt_device.$opt_vid type vlan id $opt_vid" );
	# Bring up vlan interface
	system( "ip link set dev $opt_device.$opt_vid up" );
	say "[+] Added VLAN interface $opt_device.$opt_vid\@$opt_vid";
	if ($opt_addr) {
		system( "ip address add $opt_addr dev $opt_device.$opt_vid" );
		say "[+] Added address $opt_addr to interface $opt_device.$opt_vid";
	}
	system ( "ip link set dev $opt_device.$opt_vid up" );
}

if ($opt_del) {
	say "[+] Deleting child interface $opt_device with vlan id $opt_vid";
	system ( "ip link delete $opt_device.$opt_vid" );
	say "[+] Deleted $opt_device.$opt_vid"
}
