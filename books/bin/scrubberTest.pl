#!/usr/bin/perl

use v5.10.0;
use warnings;
use strict;
use autodie;
use HTML::Scrubber;

my @args = $_;
my $file = pop() or die "No argument file given" ;
my $scrubber = HTML::Scrubber->new( allow => [ qw[ p b i u hr nl ul li h1 h2 h3 h4 h5 ] ] );
my $scrubbed = $scrubber->scrub_file($file);
say $scrubbed;