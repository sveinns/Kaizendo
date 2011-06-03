use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Test::More;
require HTTP::Request;

use TestDatastore;

my $store = buildTestData(getTestDatastore());

use_ok 'Catalyst::Test', 'App::Kaizendo::Web';
use_ok 'App::Kaizendo::Web::ControllerRole::Comment';

ok( request('/_c')->is_success, 'Root comments list request' );
ok( request('/IHE/1/_c')->is_success, '/IHE/1 comments list request' );

my $r_comments_list = HTTP::Request->new(GET => '/IHE/1/_c');
$r_comments_list->header('Accept' => 'application/json');

my $discussion = request($r_comments_list);
diag $discussion->content;

done_testing();
