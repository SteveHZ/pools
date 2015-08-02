package Pools::View::Home;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
	INCLUDE_PATH => [
		Pools->path_to ('root','src'),
		Pools->path_to ('root','static','js'),
	],
	WRAPPER => 'wrapper.tt2',
	render_die => 1,
);

=head1 NAME

Pools::View::Home - TT View for Pools

=head1 DESCRIPTION

TT View for Pools.

=head1 SEE ALSO

L<Pools>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
