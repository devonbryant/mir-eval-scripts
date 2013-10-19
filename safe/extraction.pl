##
## Safe feature extraction script.
##
use strict;
use File::Find;
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

# start timing
my $start = [gettimeofday];

# count the number of wav files
my $num = 0;
find(sub {
		if ( /\.wav$/i ) { $num += 1; }
	},
	$in_dir
);

# input & output directory paths
# my $IN_DIR = "../../../datasets/mir/audio/safe/beatles/wav";
# my $OUT_DIR = "../../../datasets/mir/out/safe";

my $plan = abs_path("plan.txt");

# path to Safe
my $safe = abs_path("../../../projects/safe/safe-core/target/run");

my $ret = system("$safe -i \"$in_dir\" -r -p \"$plan\" -o \"$out_dir\"");
if ($ret) { exit -1; }

my $elapsed = tv_interval($start);
printf("safe extracted features from %d files in %.4f seconds\n", $num, $elapsed);