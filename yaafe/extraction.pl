##
## yaafe feature extraction script.
##
use strict;
use File::Find;
use Time::HiRes qw( usleep gettimeofday tv_interval );
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

# input & output directory paths
# my $IN_DIR = "../../../datasets/mir/audio/safe/beatles/wav";
# my $OUT_DIR = "../../../datasets/mir/out/yaafe";

my $plan = "plan.txt";

my $num = 0;

# write out the audio file paths to a single file for yaafe
open(FILES, '>files.txt');

find(sub {
		if ( /\.wav$/i ) { 
			print FILES $File::Find::name . "\n";
			$num += 1;
		}
	},
	$in_dir
);

close(FILES);

my $ret = system("yaafe.py -r 44100 -c \"$plan\" -i files.txt -b \"$out_dir\"");
if ($ret) { exit -1; }

my $elapsed = tv_interval($start);
printf("yaafe extracted features from %d files in %.4f seconds\n", $num, $elapsed);