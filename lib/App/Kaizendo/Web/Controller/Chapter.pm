package App::Kaizendo::Web::Controller::Chapter;
use Moose;
use namespace::autoclean;

BEGIN { extends 'App::Kaizendo::Web::ControllerBase::REST' }

with qw/
  App::Kaizendo::Web::ControllerRole::Aspect
  App::Kaizendo::Web::ControllerRole::User
  App::Kaizendo::Web::ControllerRole::Comment
  /;

=head1 NAME

App::Kaizendo::Web::Controller::Chapter

=head1 METHODS

=head2 base

FIXME

=cut

sub base : Chained('/project/chapter') PathPart('') CaptureArgs(0) {
}

=head2 chapter

FIXME

=cut

sub chapter : Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $chapter_no ) = @_;
    my $chapter = $c->stash->{project}->get_chapter_by_number($chapter_no)
        or $c->detach('/notfound_404');
    $c->stash(chapter => $chapter);
}


sub content : Chained('chapter') PathPart('') Args(0) {
}

__PACKAGE__->config(
    action => {
        aspect_base  => { Chained => 'chapter' },
        user_base    => { Chained => 'chapter' },
        comment_base => { Chained => 'chapter' },
    },
);

=head1 NAME

App::Kaizendo::Web::Controller::Chapter

=head1 METHODS

=head2 base

FIXME

=head2 chapter

FIXME

=head2 content

FIXME

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut

__PACKAGE__->meta->make_immutable;
