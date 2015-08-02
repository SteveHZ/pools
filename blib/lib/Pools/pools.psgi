use strict;
use warnings;

use Pools;

my $app = Pools->apply_default_middlewares(Pools->psgi_app);
$app;

