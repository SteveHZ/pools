use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Pools';
use Pools::Controller::Pools;

ok( request('/')->is_success, 'Request should succeed' );
ok( request('/pools')->is_redirect, 'Request should succeed' );

done_testing();
