package App::Kaizendo::Datastore::Person;
use App::Kaizendo::Moose;  # Set up Moose for this package

# List of data points is from the Atom specification,
# See RFC 4287, section 3.2 (Person Constructs)
has name  => ( is => 'ro', isa => 'Str', required => 1 );
has uri   => ( is => 'ro', isa => 'Str' ); # FIXME: URI check
has email => ( is => 'ro', isa => 'Str' ); # FIXME: email check
has id    => ( is => 'ro', isa => 'Str', required => 1 );

has access => ( is => 'ro', isa => 'Int', default => 0 ); # FIXME: Use enum Types


subtype 'App::Kaizendo::Datastore::Author'
  => as 'App::Kaizendo::Datastore::Person'
  => where { $_->access > 0 };

sub TO_JSON {
    my $self = shift;
    my %serialized;
    foreach (qw(id name uri email)) {
        $serialized{$_} = $self->$_;
    }
    
    return \%serialized;
}


__PACKAGE__->meta->make_immutable;
1;

=head1 AUTHORS, COPYRIGHT AND LICENSE

See L<App::Kaizendo> for Authors, Copyright and License information.

=cut