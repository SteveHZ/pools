package Pools::Controller::Pools;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Pools::Controller::Pools - Catalyst Controller
v1 July 2015

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

	$c->response->redirect ($c->uri_for ($self->action_for ('home')));
}

sub base :Chained('/') PathPart('pools') CaptureArgs(0) {
	my ($self, $c) = @_;
	
	$c->stash ( data => $c->model ('pools_model')->read_teams () );
}

sub home :Chained('base') PathPart('home') {
	my ($self, $c) = @_;
	
	$c->stash ( template => 'home.tt2',	);
}

sub update :Chained('base') PathPart('update') {
	my ($self, $c) = @_;

	$c->stash ( template => 'show_data.tt2',
				data => $c->model ('pools_model')
						  ->update (),
	);
}

sub enter_fixtures :Chained('base') PathPart('enter_fixtures') {
	my ($self, $c) = @_;

	$c->stash ( template => 'enter_fixtures.tt2', );
}

sub do_fixtures :Path('do_fixtures') {
	my ($self, $c) = @_;
	
	my $params = params ($c, qw /h0 a0 h1 a1 h2 a2 h3 a3 h4 a4 h5 a5/);
	my $fixtures = $c->model ('pools_model')
					 ->fixture_list ($params);
	
	$c->stash ( template => 'do_fixtures.tt2',
				fixtures => $fixtures,
#				data - this could return fixtures as part of a hash ???
#predictions => $c->model ('pools_model')->predictions ($fixtures),
	);
}
	
sub params {
	my ($c, @params) = @_;
	my $hash = {};
	
	$hash->{$_} = $c->request->params->{$_} foreach (@params);
	return $hash;
}
	
=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
