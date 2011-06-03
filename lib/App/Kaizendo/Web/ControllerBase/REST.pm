package App::Kaizendo::Web::ControllerBase::REST;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

# Catalyst::Action::Serialize handles serializing
sub serialize : ActionClass('Serialize') {}

sub end : Action {
    my ( $self, $c ) = @_;
    $c->forward('serialize')
      unless $c->response->body;
    die("Forced debug") if $c->debug
        && $c->request->param('dump_info');
}

__PACKAGE__->config(
    default      => 'text/html',
    stash_key    => 'rest',
    json_options => { allow_blessed => 1, relaxed => 1 },
    map          => {
        'text/html'        => [ 'View', 'HTML', ],
        'application/json' => 'JSON',
        'text/x−json'      => 'JSON',
    },
);

=head1 NAME

App::Kaizendo::Web::ControllerBase::REST

=head2 serialize

The content serializer

=head2 end

Forwards to content serializer if there's no response body

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut

__PACKAGE__->meta->make_immutable;
