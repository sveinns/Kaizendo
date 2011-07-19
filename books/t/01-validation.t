#!perl -T

use Test::More tests=> 20;
use WebService::Validator::HTML::W3C;

# HTML preamble and postamble:
my $html_top =<<'HTML_TOP';
<!DOCTYPE html>
<html>
<head>
<meta name="generator" content=
"HTML Tidy for Linux/x86 (vers 25 March 2009), see www.w3.org">
<title></title>
</head>
<body>
HTML_TOP
my $html_bottom ="</body>\n</html>";

my @files;
foreach (1 .. 9) {
	$files[$_-1] = "www.dreamsongs.com/IHE/plain/ch$_.html";
}

my $v = WebService::Validator::HTML::W3C->new(
		    detailed    =>  1
		    );

#Tests begin
ok($v->validate(string => "$html_top<p>Hello</p>$html_bottom"), "validation is available");
ok($v->is_valid, "Validation mechanism works on a simple html file.");

foreach (@files){
	open my $fh , '<', $_;
	my $text = do { local $/ = <$fh> }; #the file in $_ is slurped
	ok($v->validate(string => $html_top . $text . $html_bottom), "$_ is validated");
	ok($v->is_valid, "$_ is valid body of html");

	#print errors if html is invalid, so as to have good feedback during testing.
	unless ($v->is_valid) {
	
	    my $errors = $v->errors();
		foreach my $err ( @$errors ) {
			diag sprintf("line: %s, col: %s\n\terror: %s\n", 
				    $err->line, $err->col, $err->msg);
    	}
	}
}


diag( "Testing Books $Books::VERSION, Perl $], $^X" );
done_testing();
