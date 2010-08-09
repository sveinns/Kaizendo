#!/usr/bin/env perl
#
# Usage: script/add_id.pl < t/data/IHE/ch1.html | less
#

use HTML::Tree;
use Digest::SHA1 qw(sha1_base64);
use IO::All;

use warnings;
use strict;

my $io = io->stdin;
my $content = $io->all;
my $content_sha1 = sha1_base64($content);

# Let's identify the content
$content = qq(<div id="_modified_content_root" class="$content_sha1">$content</div>); # Show that we have

# Set up the HTML::TreeBuilder parser
my $tree = HTML::TreeBuilder->new();
$tree->implicit_tags(0);
$tree->implicit_body_p_tag(0);
$tree->ignore_unknown(0);
$tree->ignore_ignorable_whitespace(0);
$tree->no_space_compacting(1);
$tree->store_comments(1);

$tree->parse($content);
$tree->eof();

$tree = $tree->look_down(_tag => 'div', class => $content_sha1); # Find the real root

{
  my $counter = 0;
  sub give_id {
    my $x = $_[0];
    $x->attr('id', 'c_' . $counter++) unless defined $x->attr('id');
    foreach my $c ($x->content_list) {
      give_id($c) if ref $c; # ignore text nodes
    }
  };
  give_id($tree);
}

print $tree->as_HTML("", "  ", {});
