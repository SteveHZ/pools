
#	pools_app.t 31/08/15

#	usage on command line in pools directory :
#	set catalyst_debug=0
#	perl -w -Ilib t/pools_app.t

# 	OR prove -wl t in pools directory

use strict;
use warnings;
use Test::More;
 
use Test::WWW::Mechanize::Catalyst "Pools";
#BEGIN { use_ok("Test::WWW::Mechanize::Catalyst" => "Pools") }
 
my $user = Test::WWW::Mechanize::Catalyst->new;

$user->get_ok("http://localhost:3000/pools", "Goto Localhost/pools");
$user->title_is("Football Pools - Home", "Check title is 'Football Pools - Home'");
$user->get_ok("http://localhost:3000/pools/home", "Goto pools/home");
$user->title_is("Football Pools - Home", "Check title is 'Football Pools - Home'");

print "\n";
$user->follow_link_ok({n => 2}, "Follow update link");
$user->title_is("Football Pools - Update", "Check title is Football Pools - Update");
$user->get_ok("http://localhost:3000/pools/home", "Back to Home page");
$user->title_is("Football Pools - Home", "Check title is 'Football Pools - Home'");

print "\n";
$user->follow_link_ok({n => 3}, "Follow Super6 Enter Fixtures link");
$user->submit_form (
    fields => {
        h0 => 'Arsenal',		a0 => 'Aston Villa',
		h1 => 'Chelsea',		a1 => 'Crystal Palace',
        h2 => 'Leicester', 		a2 => 'Liverpool',
		h3 => 'Man City', 		a3 => 'Man United',
        h4 => 'Southampton', 	a4 => 'Stoke',
		h5 => 'West Brom', 		a5 => 'West Ham',
    });
	
$user->title_is("Football Pools - Predictions", "Check title is Football Pools - Predictions");
$user->content_contains("Arsenal", "Check teams on page");
$user->get_ok("http://localhost:3000/pools/home", "Back to Home page");
$user->title_is("Football Pools - Home", "Check title is 'Football Pools - Home'");

print "\n";
$user->follow_link_ok({n => 4}, "Follow Super6 Test Fixtures link");
$user->title_is("Football Pools - Predictions", "Check title is Football Pools - Predictions");
$user->get_ok("http://localhost:3000/pools/home", "Back to Home page");
$user->title_is("Football Pools - Home", "Check title is 'Football Pools - Home'");

print "\n";
$user->follow_link_ok({n => 5}, "Follow Pools Enter Fixtures link");
$user->submit_form (
    fields => {
        h0 => 'Arsenal',		a0 => 'Aston Villa',
		h1 => 'Chelsea',		a1 => 'Crystal Palace',
        h2 => 'Leicester', 		a2 => 'Liverpool',
		h3 => 'Man City', 		a3 => 'Man United',
        h4 => 'Southampton', 	a4 => 'Stoke',
		h5 => 'West Brom', 		a5 => 'West Ham',
    });
	
$user->title_is("Football Pools - Predictions", "Check title is Football Pools - Predictions");
$user->content_contains("Arsenal", "Check teams on page");
$user->get_ok("http://localhost:3000/pools/home", "Back to Home page");
$user->title_is("Football Pools - Home", "Check title is 'Football Pools - Home'");

print "\n";
$user->follow_link_ok({n => 6}, "Follow Pools Test Fixtures link");
$user->title_is("Football Pools - Predictions", "Check title is Football Pools - Predictions");
$user->get_ok("http://localhost:3000/pools/home", "Back to Home page");
$user->title_is("Football Pools - Home", "Check title is 'Football Pools - Home'");


done_testing ();

=head2
# Create two 'user agents' to simulate two different users ('test01' & 'test02')
my $ua1 = Test::WWW::Mechanize::Catalyst->new;
my $ua2 = Test::WWW::Mechanize::Catalyst->new;
 
# Use a simplified for loop to do tests that are common to both users
# Use get_ok() to make sure we can hit the base URL
# Second arg = optional description of test (will be displayed for failed tests)
# Note that in test scripts you send everything to 'http://localhost'
$_->get_ok("http://localhost/", "Check redirect of base URL") for $ua1, $ua2;
# Use title_is() to check the contents of the <title>...</title> tags
$_->title_is("Login", "Check for login title") for $ua1, $ua2;
# Use content_contains() to match on text in the html body
$_->content_contains("You need to log in to use this application",
    "Check we are NOT logged in") for $ua1, $ua2;
 
# Log in as each user
# Specify username and password on the URL
$ua1->get_ok("http://localhost/login?username=test01&password=mypass", "Login 'test01'");
# Could make user2 like user1 above, but use the form to show another way
$ua2->submit_form(
    fields => {
        username => 'test02',
        password => 'mypass',
    });
 
# Go back to the login page and it should show that we are already logged in
$_->get_ok("http://localhost/login", "Return to '/login'") for $ua1, $ua2;
$_->title_is("Login", "Check for login page") for $ua1, $ua2;
$_->content_contains("Please Note: You are already logged in as ",
    "Check we ARE logged in" ) for $ua1, $ua2;
 
# 'Click' the 'Logout' link (see also 'text_regex' and 'url_regex' options)
$_->follow_link_ok({n => 4}, "Logout via first link on page") for $ua1, $ua2;
$_->title_is("Login", "Check for login title") for $ua1, $ua2;
$_->content_contains("You need to log in to use this application",
    "Check we are NOT logged in") for $ua1, $ua2;
 
# Log back in
$ua1->get_ok("http://localhost/login?username=test01&password=mypass",
    "Login 'test01'");
$ua2->get_ok("http://localhost/login?username=test02&password=mypass",
    "Login 'test02'");
# Should be at the Book List page... do some checks to confirm
$_->title_is("Book List", "Check for book list title") for $ua1, $ua2;
 
$ua1->get_ok("http://localhost/books/list", "'test01' book list");
$ua1->get_ok("http://localhost/login", "Login Page");
$ua1->get_ok("http://localhost/books/list", "'test01' book list");
 
$_->content_contains("Book List", "Check for book list title") for $ua1, $ua2;
# Make sure the appropriate logout buttons are displayed
$_->content_contains("/logout\">User Logout</a>",
    "Both users should have a 'User Logout'") for $ua1, $ua2;
$ua1->content_contains("/books/form_create\">Admin Create</a>",
    "'test01' should have a create link");
$ua2->content_lacks("/books/form_create\">Admin Create</a>",
    "'test02' should NOT have a create link");
 
$ua1->get_ok("http://localhost/books/list", "View book list as 'test01'");
 
# User 'test01' should be able to create a book with the "formless create" URL
$ua1->get_ok("http://localhost/books/url_create/TestTitle/2/4",
    "'test01' formless create");
$ua1->title_is("Book Created", "Book created title");
$ua1->content_contains("Added book 'TestTitle'", "Check title added OK");
$ua1->content_contains("by 'Stevens'", "Check author added OK");
$ua1->content_contains("with a rating of 2.", "Check rating added");
# Try a regular expression to combine the previous 3 checks & account for whitespace
$ua1->content_like(qr/Added book 'TestTitle'\s+by 'Stevens'\s+with a rating of 2./,
    "Regex check");
 
# Make sure the new book shows in the list
$ua1->get_ok("http://localhost/books/list", "'test01' book list");
$ua1->title_is("Book List", "Check logged in and at book list");
$ua1->content_contains("Book List", "Book List page test");
$ua1->content_contains("TestTitle", "Look for 'TestTitle'");
 
# Make sure the new book can be deleted
# Get all the Delete links on the list page
my @delLinks = $ua1->find_all_links(text => 'Delete');
# Use the final link to delete the last book
$ua1->get_ok($delLinks[$#delLinks]->url, 'Delete last book');
# Check that delete worked
$ua1->content_contains("Book List", "Book List page test");
$ua1->content_like(qr/Deleted book \d+/, "Deleted book #");
 
# User 'test02' should not be able to add a book
$ua2->get_ok("http://localhost/books/url_create/TestTitle2/2/5", "'test02' add");
$ua2->content_contains("Unauthorized!", "Check 'test02' cannot add");

#diag $user->content; # show full HTML page source
 
=cut
