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
my $teams_xml = $path.'teams.xml';
#my $teams = $path.'teamsblank 2015.csv';
my $teamstest = $path.'teamstest.csv';

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

sub write_teams {
	my ($file, $filetype) = @_;

	my $tt = Template->new;
	open my $out, '>:raw', "$file"
		or die "Can't create $file : $!\n";

	$tt->process ("root/src/teams_${filetype}.tt2",
		{ data => \%league }, $out)
		or die $tt->error;
	close $out;
}

sub write_teams_csv { write_teams ($teams, 'csv'); }
sub write_teams_xml { write_teams ($teams_xml, 'xml'); }

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
	write_teams_csv ();
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

=head2

sub old_write_teams {
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

=cut

__PACKAGE__->meta->make_immutable;

1;
