package App::Kaizendo::Datastore::ProjectSnapshot;
use App::Kaizendo::Moose;  # Set up Moose environment
use MooseX::Types::Moose qw/ ArrayRef /;

use aliased 'App::Kaizendo::Datastore::Chapter';

# Predeclare type to avoid circular class refereneces
class_type 'App::Kaizendo::Datastore::Project'; 

has project => (
    isa => 'App::Kaizendo::Datastore::Project',
    is => 'ro',
    required => 1,
    handles => [qw/
        name
        title
    /],
    weak_ref => 1,
);

has updated => (
    is => 'rw',
    isa => 'DateTime',
    default => sub { DateTime->now(); }
);

# Each new snapshot has a tag (e.g. "v1.0" or "v1.2") - think revision tagging
has tag => (
    is => 'ro',
    required => 1,
);

has commit_message => (
    is => 'rw',
);

has editor => ( is => 'rw', isa => 'App::Kaizendo::Datastore::Person' );

has chapters => (
    is => 'ro',
    isa => ArrayRef,
    default => sub { [] },
    traits     => ['Array'],
    handles => {
        no_of_chapters => 'count',
        get_chapter_by_number => 'get',
    },
);

around get_chapter_by_number => sub {
    my ($orig, $self, $no) = @_;
    $self->$orig($no - 1);  # Chapters start at 1, arrays at 0
};

method append_chapter (%args) {

    # Set up new chapter object
    my $new_chapter = Chapter->new(
        project => $self->project,
        id      => $self->no_of_chapters + 1,
        content => $args{content},
        author  => $args{author}, );

    my $new_snapshot = blessed($self)->new(
        project  => $self->project,
        chapters => [
            $self->chapters->flatten,
            $new_chapter, # Append chapter
        ],
        tag      => $args{tag},
        comment  => $args{comment},
    );
    $self->project->_add_snapshot($new_snapshot);
    return $new_snapshot;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

App::Kaizendo::Datastore::ProjectSnapshot - A project at a specific point in time

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut
