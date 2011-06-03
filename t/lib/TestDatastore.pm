package TestDatastore;
use Exporter ();
use Moose::Autobox;
use Test::More;
use FindBin qw/$Bin/;
use aliased 'App::Kaizendo::Datastore';
use aliased 'App::Kaizendo::Datastore::Project';
use aliased 'App::Kaizendo::Datastore::Comment';
use aliased 'App::Kaizendo::Datastore::Location';
use aliased 'App::Kaizendo::Datastore::Person';

our @EXPORT = qw/getTestDatastore buildTestData/;

my $to_unlink;
my $fn;

sub import {
    my ($class, $args) = @_;
    pop if $args;
    $fn = $Bin . '/../kiokudb.sqlite3';
    unless ($args->{no_unlink}) {
        $to_unlink = $fn;
    }
    my @needed = qw/
        DBIx::Class::Optional::Dependencies
    /;
    plan skip_all => "One of the required classes for this test $@ (" . join(',', @needed) . ") not found."
        unless eval {
            Class::MOP::load_class($_) for @needed; 1;
        };
    plan skip_all => 'Test needs ' . DBIx::Class::Optional::Dependencies->req_missing_for('deploy')
        unless DBIx::Class::Optional::Dependencies->req_ok_for('deploy');
    goto &Exporter::import;
}

sub getTestDatastore {
    unlink $fn if -f $fn;
    my $storage = Datastore->new(
        dsn => "dbi:SQLite:dbname=$fn",
        extra_args => { create => 1, },
    );
    system("chmod 666 $fn");
    return $storage;
}

sub buildTestData {
    my ($store) = @_;
    my $s = $store->new_scope;

    my $author1 = Person->new(
        id => 1,
        name => "Ron Goldman",
        access => 1,
        email => q<ron@example.net>,
        uri => "/_user/ron" );
    ok $author1, 'Register first author';

    my $author2 = Person->new(
        id => 2,
        name => "Richard P. Gabriel",
        access => 1,
        email => q<rich@example.net>,
        uri => "/_user/rich" );
    ok $author2, 'Register second author';

    my $doc = Project->new(name => 'IHE');
    ok $doc, 'Create initial project';
    
    is scalar($doc->snapshots->flatten), 1, '..and check it has 1 snapshot';

    ok $doc->title("Innovation Happens Elsewhere"), 'Set project title';

    # Add snapshots with new chapters
    my $latest_snapshot = $doc->latest_snapshot;
    my (@chapter_fns) = glob($Bin.'/data/IHE/ch*.html');
    ok scalar(@chapter_fns), 'There are some chapters in '."$Bin/data/IHE";
    for my $fn (@chapter_fns) {
        my ($fh, $version);
        open($fh, '<', $fn) or die $!;
        my $data = do { local $/; <$fh> };
        $latest_snapshot = $latest_snapshot->append_chapter(
            content        => $data,
            author         => $author1,
            commit_message => "Add chapter from " . $fn,
            tag            => "v0.0." . ++$version, #
        );
    }
    $store->store($doc);

    # Specify some locations
    my $location1 = Location->new(
        id  => 1,
        url => '/IHE/1/',
        start_path => '/div/p:[1]',
        start_offset => 31,
        end_path => '/div/p:[1]',
        end_offset => 70,
        child_paths => [],
      );
    ok $location1, "Created location 1";
    ok $store->store($location1), "Stored location 1";

    my $location2 = Location->new(
        id  => 2,
        url => '/IHE/1/',
        start_path => '/div/p:[1]',
        start_offset => 62,
        end_path => '/div/p:[1]',
        end_offset => 121,
        child_paths => [],
      );
    ok $location2, "Created location 2";
    ok $store->store($location2), "Stored location 2";

    my $location3 = Location->new(
        id  => 3,
        url => '/IHE/1/',
        start_path => '/div/p:[1]',
        start_offset => 286,
        end_path => '/div/p:[1]',
        end_offset => 300,
        child_paths => [],
      );
    ok $location3, "Created location 3";
    ok $store->store($location3), "Stored location 3";


    # Create some comments
    my $comment1 = Comment->new(
        id => 1,
        author  => $author2,
        in_reply_to => undef,
        subject => "This is racist",
        content => "expand that thinking!",
        location => $location1,
      );
    ok $comment1, "Created comment 1";
    ok $store->store($comment1), "Stored comment 1";

    my $comment2 = Comment->new(
        id => 2,
        author  => $author1,
        in_reply_to => undef,
        subject => "This is wrong",
        content => "What lessons?",
        location => $location2,
      );
    ok $comment1, "Created comment 2";
    ok $store->store($comment2), "Stored comment 2";

    my $comment3 = Comment->new(
        id => 3,
        author  => $author2,
        in_reply_to => undef,
        subject => "This is making an assumption",
        content => "Not me!",
        location => $location3,
      );
    ok $comment1, "Created comment 3";
    ok $store->store($comment1), "Stored comment 3";

    return $store;
}

END {
    if ($to_unlink) {
        unlink $to_unlink;
    }
    else {
        diag "Left database $fn un cleaned up";
    }
}

1;
