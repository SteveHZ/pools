use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Pools';
use Pools::Controller::Pools;

ok( request('/pools')->is_success, 'Request should succeed' );
done_testing();
