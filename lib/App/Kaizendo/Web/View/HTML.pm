package App::Kaizendo::Web::View::HTML;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::View::TT' }

__PACKAGE__->config({
	render_die => 0,
	TEMPLATE_EXTENSION => '.html',
	PLUGIN_BASE => 'App::Kaizendo::Template::Plugin',
});

=head1 NAME

App::Kaizendo::Web::View::HTML - TT View for App::Kaizendo::Web

=head1 DESCRIPTION

TT View for App::Kaizendo::Web. 

=head1 SEE ALSO

L<App::Kaizendo::Web>

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut

1;
