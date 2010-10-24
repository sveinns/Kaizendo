use v5.10.0;
use warnings;
use strict;

my $string = "";
my $chapter = 1;
my @chapterstarts = (10,18,25,35,42,52,60, 66,72,84);
my $start = shift @chapterstarts;
for my $end (@chapterstarts) {
	for my $i ($start .. $end-1) {
		$string .= " IHE-$i.html";
	}
	
	system "perl convert.pl $string $chapter";
	$start = $end;
	$string = "";
	my $chapterfile = "plain/ch" . $chapter . ".html";
	system "tidy -o plain/ch$chapter.html -i plain/ch$chapter.html";
	$chapter++;
}
