##
## sonic-annotator feature extraction script.
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

# count the number of wav files
my $num = 0;
find(sub {
		if ( /\.wav$/i ) { $num += 1; }
	},
	$in_dir
);

# input & output directory paths
# my $IN_DIR = "../../../datasets/mir/audio/safe/beatles/wav";
# my $OUT_DIR = "../../../datasets/mir/out/sonic_annotator";

my $plan = abs_path("plan.n3");

# path to sonic-annotator
my $sonic_annotator = abs_path("../../../resources/mir/sonic-annotator-1.0-osx-x86_64/sonic-annotator");

my $ret = system("$sonic_annotator -t \"$plan\" -w csv --csv-force --csv-basedir \"$out_dir\" -r \"$in_dir\"");
if ($ret) { exit -1; }

my $elapsed = tv_interval($start);
printf("sonic-annotator extracted features from %d files in %.4f seconds\n", $num, $elapsed);