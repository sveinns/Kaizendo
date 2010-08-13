package App::Kaizendo::Template::Plugin::AddID;
use Moose;
use MooseX::NonMoose;
use namespace::autoclean;

use HTML::Tree;
use Digest::SHA1 qw(sha1_hex);

use Template::Plugin::Filter;
extends qw( Moose::Object Template::Plugin::Filter );

sub BUILDARGS {
    my ( $class, $c, @args ) = @_;

    my $filter_args = { @args };

	return { %$filter_args, context => $c, filter_args => $filter_args };
}


sub init {
    my $self = shift;

    $self->install_filter('add_ids');

    return $self;
}

sub filter {
    my ($self, $text) = @_;

    $text = _add_ids($text);

    return $text;
}

sub _add_ids {
    my $content = shift;
    my $content_sha1 = sha1_hex($content);
    $content = qq(<div id="_modified_content_root" class="$content_sha1">$content</div>); # Show that we have

    my $tree = HTML::TreeBuilder->new();
    $tree->implicit_tags(0);
    $tree->implicit_body_p_tag(0);
    $tree->ignore_unknown(0);
    $tree->ignore_ignorable_whitespace(1);
    $tree->no_space_compacting(0);
    $tree->store_comments(1);

    $tree->parse($content);
    $tree->eof();
    my $guts = $tree->disembowel();

    my $id_counter = 0;
    _assign_id($guts, $id_counter);
    return $guts->as_HTML("", "  ", {});
}


sub _assign_id {
    my $x = $_[0];
    my $counter = $_[1];
    my $pos;
    $x->id('c_' . $counter++) unless defined $x->id;
    if( $x->content_list > 1) {
        foreach my $c ($x->content_list) {
            if (ref $c) {
                _assign_id($c, $counter);
            }
            else { 
                my $s = HTML::Element->new('span', id => 'c_' . $counter++);
                $s->push_content($c); # Wrap content with a span element
                $x->splice_content( $pos, 1, $s );
            }
            $pos++;
        }
    }
}


=head1 NAME

App::Kaizendo::Template::Plugin::AddID - TT Filter for adding ID attributes

=head1 DESCRIPTION

This module is a TT Filter for adding ID attributes to elements in a HTML
document.

=head1 SYNOPSIS

  [% USE AddID %]

  [% content | add_id %]


=head1 WHAT IT IS FOR

The algorithm used is based on COMT's discussion tool for text annotations,
described at L<http://www.co-ment.org/wiki/AnnotationInternals>.

The strategy is to traverse the content depth-first, adding unique IDs
as we go:

   - The content is wrapped with a <span> having the object
     UUID of the content as id
   - Elements that don't have an ID get one
   - Elements with an ID keep the one they have
   - Whitespace CDATA is stripped
   - Content CDATA get a <span> with an ID around it


=head1 SEE ALSO

L<App::Kaizendo::Web>, L<Template::Plugin::Filter>

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut

1;
