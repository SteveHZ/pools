package Pools::Model::pools_model;
use Moose;
use namespace::autoclean;

use Team;
use Score;

extends 'Catalyst::Model';

=head1 NAME

Pools::Model::pools_model - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

my %league=();

my $path = 'root/static/data/';

my $premdata = $path.'E0.csv';
my $teams = $path.'teams.csv';
#my $teams = $path.'teamsblank 2015.csv';
my $teamstest = $path.'teamstest.csv';
my $new_teams = $path.'new_teams.csv';

sub read_teams {
	my (@stats);
	my ($line,$div,$teamNo,$team);

	open (FH,'<',$teams) or die ("Can't find teams.csv");
	while ($line = <FH>) {
		($teamNo,$team,@stats) = split (/,/,$line);
		$league{$team} = Team->new ($teamNo,\@stats);
	}
	close FH;
	return \%league;
}

sub update {
	my ($line,$home,$away,$h,$a,$junk,@junk);

	open (FH,'<',$premdata) or die ("Can't find $premdata");
	$line = <FH>;
	while ($line = <FH>) {
		($junk,$junk,$home,$away,$h,$a,@junk) = split (/,/,$line);

#		shift existing array down
		shift $league{$home}->home ();
		shift $league{$away}->away ();

		push $league{$home}->home (), Score->new ($h, $a);			
		push $league{$away}->away (), Score->new ($a, $h);
	}
	close FH;
#	write_teams ();
	new_write_teams ();
	return \%league;
}

sub fixture_list {
	my ($self, $params) = @_;
	
	return	[ 	{ 'home' => $params->{'h0'}, 'away' => $params->{'a0'} },
				{ 'home' => $params->{'h1'}, 'away' => $params->{'a1'} },
				{ 'home' => $params->{'h2'}, 'away' => $params->{'a2'} },
				{ 'home' => $params->{'h3'}, 'away' => $params->{'a3'} },
				{ 'home' => $params->{'h4'}, 'away' => $params->{'a4'} },
				{ 'home' => $params->{'h5'}, 'away' => $params->{'a5'} },
			];
}

sub write_teams {
	my ($key,$str);
	my (@sorted);

	open (FH,'>',$teams) or die ("Can't create teams.csv");

	@sorted = sort {$a cmp $b} ( keys %league );
	foreach $key (@sorted) {
		$str = [];
		$league{$key}->csvStats ($str);			

		print FH $league{$key}->teamNo (),",";
		print FH $key,",";
		print FH $_ foreach (@$str);
		print FH "\n";
	}
	close FH;
}

sub new_write_teams {
	my $tt = Template->new;
	open my $out, '>:raw', $teams or die "Can't create $teams: $!\n";

	$tt->process ('root/src/teams_csv.tt2',
		{ data => \%league }, $out)
		or die $tt->error;
	close $out;
}



__PACKAGE__->meta->make_immutable;

1;
