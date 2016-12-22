# Copyright (c) 2016 Electric Cloud, Inc.
# All rights reserved.
# 
# Github Webhooks event listener
# 

use strict;

use lib 'lib';

use Plack::App::GitHub::WebHook;
use Data::Dumper;
# use Data::Dumper::Concise;



#
# 1 # - Section parses configuration file
#

# listener.conf 
open FL, '<', 'listener.conf' or die; 
undef $/; my $conf_file = <FL>; close FL;


my @a = split("\n", $conf_file);
my @b;
for (@a) {
	if (!/^#/) {push(@b, $_);}
} 
$conf_file = join("\n", @b);

$conf_file =~ s/(\r\n|\r|\n){2,}/\n\n/g;

@a = split("\n{2,}", $conf_file);

my %hconf;
my $repo_cnt;

for my $block(@a) {
	next if ($block eq '');

	$block =~ s/^(\r\n|\r|\n)+//;

	if ($block =~ /^server/) {
		my @conf_pat = qw(ef_server ef_user ef_password);

		@b = split("\n", $block);
		for my $line (@b) {
			for my $pat (@conf_pat) {
				if ($line =~ m/$pat\s+('|")(.*?)('|")/) {
					$hconf{$pat} = $2;
				}
			}
		}
	}

	if ($block =~ /^github/) {
		my @conf_pat = qw(gh_secret);

		@b = split("\n", $block);
		for my $line (@b) {
			for my $pat (@conf_pat) {
				if ($line =~ m/$pat\s+('|")(.*?)('|")/) {
					$hconf{$pat} = $2;
				}
			}
		}
	}

	my %hrepos;
	if ($block =~ /^repository/) {
		$repo_cnt++;
		my @conf_pat = qw(repo_name run_batch);
		
		@b = split("\n", $block);
		for my $line (@b) {
			for my $pat (@conf_pat) {
				if ($line =~ m/$pat\s+('|")(.*?)('|")/) {
					$hrepos{$pat} = $2;
				}
			}
		}
		$hconf{"repo" . "_r$repo_cnt"} = \%hrepos;
	}
}

# debug
# while ( my ($key, $value) = each(%hconf) ) { print "$key => $value\n"; } print "---\n";
# print Dumper(\%hconf), "\n";

# OUTPUT
# $VAR1 = {
#           'ef_password' => 'changeme',
#           'repo_r2' => {
#                          'run_batch' => 'D:\\_source\\GitHub_webhooks\\src\\shell\\ec_run_build_A.cmd',
#                          'repo_name' => 'abstract1'
#                        },
#           'repo_r1' => {
#                          'repo_name' => 'abstract12',
#                          'run_batch' => 'D:\\_source\\GitHub_webhooks\\src\\shell\\ec_run_build_B.cmd'
#                        },
#           'ef_user' => 'admin',
#           'ef_server' => '192.168.1.16'
#           'gh_secret' => 'pqMExxxxxxxxxxF9qi',
#         };

# Check if we got the repository registed in the configuration file
sub is_repo_from_cfg {
	my $gotRepo = shift;
	
	foreach my $akey (keys %hconf) {
	    if ($akey =~ /repo_/) {
		    if ($hconf{$akey}{repo_name} eq $gotRepo) { return $akey }
	    }
	}

	return 0;
}



#
# 2 # - Dispatcher. Handles requests from GH
#

my @code_arr;
push(@code_arr, 

	sub { 
		my $payload = shift;

		my $exec_res;
		my $gotRepo = $payload->{repository}{name};

		print "Got repo wh: $gotRepo\n";

		my $root_repo_key = is_repo_from_cfg($gotRepo); # 0 or string - 1-lev. hash key (for ex. 'repo_r2')

		if ($root_repo_key) {
			print "Serving repo - $gotRepo\n";
			print "Running batch: $hconf{$root_repo_key}{run_batch} \n";

			# Interaction with EF
			my $exec_time = scalar localtime;
			$exec_res = `$hconf{$root_repo_key}{run_batch} "$gotRepo" "$exec_time"`;
			
			if ($exec_res =~ m/(.{8}-.{4}-.{4}-.*?-.{12})/) {
				print "JOB ID: '", $1, "'\n"; 
			}
			else {
				print "Execution result: ", $exec_res, "\n";
			}
		}
		else {
			print "Got repo which is not listed in the configuration file\n";
		}
	}
);



#
# 3 # - Set up and start the listener
#

Plack::App::GitHub::WebHook->new(

    hook 	=> \@code_arr,
    events 	=> ['push'],
    secret 	=> $hconf{gh_secret},
    access 	=> 'github',

)->to_app;
