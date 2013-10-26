##
## openSMILE feature extraction script.
##
use strict;
use File::Find;
use File::Path qw(remove_tree);
use Time::HiRes qw( usleep gettimeofday tv_interval );
use Cwd 'abs_path';
use Getopt::Long;

my $in_dir = '';
my $out_dir = '';

GetOptions ("in=s" => \$in_dir, "out=s" => \$out_dir);

validate("-in", $in_dir);
validate("-out", $out_dir);

sub validate {
	my $name = shift;
	my $param = shift;
	unless(defined($param) && $param ne '') {
		die("Required parameter ($name) not specified")
	}
}

# clear out the output dir
remove_tree($out_dir, {keep_root=>1});

# start timing
my $start = [gettimeofday];

# input & output directory paths
# my $IN_DIR = "../../../datasets/mir/audio/safe/beatles/wav";
# my $OUT_DIR = "../../../datasets/mir/out/openSMILE";

my $plan = abs_path("plan.conf");

# path to openSMILE
my $openSMILE = abs_path("../../../resources/mir/opensmile-2.0-rc1/opensmile/inst/bin/SMILExtract");

my $num = 0;

find(sub {
		if ( /\.wav$/i ) { extract($_, $File::Find::name); }
	},
	$in_dir
);

sub extract {
	my $base_name = shift;
	my $file_path = shift;

	my $mfcc_out = $out_dir . "/" . $base_name . ".mfcc.csv";
	my $flux_out = $out_dir . "/" . $base_name . ".flux.csv";
	my $stats_out = $out_dir . "/" . $base_name . ".stats.csv";

	my $ret = system("$openSMILE -C \"$plan\" -I \"$file_path\" -M \"$mfcc_out\" -F \"$flux_out\" -S \"$stats_out\"");
	if ($ret) { exit -1; }

	$num += 1;
}

my $elapsed = tv_interval($start);
printf("openSMILE extracted features from %d files in %.4f seconds\n", $num, $elapsed);