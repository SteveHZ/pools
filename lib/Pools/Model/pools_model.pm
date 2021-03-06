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
pools_model

=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

my %league=();

my $path = 'C:/Mine/perl/Pools/root/static/data/';

my $premdata = $path.'E0.csv';
my $teams = $path.'teams.csv';

#my $teams = $path.'teamsblank 2015.csv';
#my $teams_xml = $path.'teams.xml';
#my $teamstest = $path.'teamstest.csv';
#my $teamstestxml = $path.'teamstest.xml';

sub read_teams {
	my (@stats);
	my ($line, $div, $teamNo, $team);

	open (FH,'<', $teams) or die ("Can't find $teams");
	while ($line = <FH>) {
		($teamNo, $team, @stats) = split (/,/, $line);
		$league {$team} = Team->new ($teamNo, \@stats);
	}
	close FH;
	return \%league;
}

sub write_teams {
	my ($file) = @_;
	
	if ($file =~ /^(\S+)\.			# full path, filename and dot
				(?<ext>\w{3}$)		# file extension
				/x ) {
		my $filetype = $+{ext};	# dont need filename, can just do label for ext

		my $tt = Template->new;
		open my $out, '>:raw', "$file"
			or die "Can't create $file : $!\n";

		$tt->process ("root/src/teams_${filetype}.tt2",
			{ data => \%league }, $out)
			or die $tt->error;
		close $out;
	} else {
		die "Unknown filetype !!!";
	}
}

sub update {
	my ($line, $home, $away, $h, $a);
	my ($junk, @junk);

	open (FH,'<', $premdata) or die ("Can't find $premdata");
	$line = <FH>;
	while ($line = <FH>) {
		($junk, $junk, $home, $away, $h, $a, @junk) = split (/,/, $line);

#		shift existing array down
		shift @{ $league{$home}->homes () };
		shift @{ $league{$away}->aways () };

		push @{ $league{$home}->homes () }, Score->new ($h, $a);			
		push @{ $league{$away}->aways () }, Score->new ($a, $h);
	}
	close FH;
	write_teams ($teams);
	return \%league;
}

sub fixture_list {
	my ($self, $params) = @_;
	
	return [
		{ home => $params->{h0}, away => $params->{a0} },
		{ home => $params->{h1}, away => $params->{a1} },
		{ home => $params->{h2}, away => $params->{a2} },
		{ home => $params->{h3}, away => $params->{a3} },
		{ home => $params->{h4}, away => $params->{a4} },
		{ home => $params->{h5}, away => $params->{a5} },
	];
}

sub get_test_fixtures {

	return [
		{ home => 'Arsenal',	away => 'Aston Villa' },
		{ home => 'Chelsea', 	away => 'Crystal Palace' },
		{ home => 'Leicester', 	away => 'Liverpool' },
		{ home => 'Man City', 	away => 'Man United' },
		{ home => 'Southampton',away => 'Stoke' },
		{ home => 'West Brom', 	away => 'West Ham' },
	];
}

sub predictions {
	my ($self, $fixtures) = @_;
	my $sorted;
	
	foreach my $match (@$fixtures) {
		$match->{draw_predict} = predict_draws ($match);
		$match->{score_predict} = predict_scores ($match);
	}
	$sorted = [ sort {$b->{draw_predict} <=> $a->{draw_predict} } @$fixtures ];
	return $sorted;
}

sub predict_draws {
	my ($match) = shift;
	my ($homes, $aways, $game, $total, $h, $a);

	my $home = $match->{home};
	my $away = $match->{away};
	$h = 0; $a = 0;

	foreach $homes ($league{$home}->homes()) {
		foreach $game(@$homes) {
			$h++ if $game->result() eq 'D' || $game->result() eq "N";
		}	
	}
	foreach $aways ($league{$away}->aways ()) {
		foreach $game (@$aways) {
			$a++ if $game->result() eq "D" || $game->result() eq "N";
		}
	}
	$total = sprintf ("%.2f", ($h/6 * 50) + ($a/6 * 50));
	return $total;
}

sub predict_scores {
	my ($match) = shift;
	my ($homes, $aways, $game);
	my ($high_home, $high_away);
	my ($mean_home, $mean_away);
	
	my ($h, $a,	$highh, $higha) = (0,0,0,0);
	my ($lowh, $lowa) = (100,100);
	my $home = $match->{home};
	my $away = $match->{away};
	
	foreach $homes ($league{$home}->homes()) {
		foreach $game(@$homes) {
			$h += $game->home ();
			$highh = $game->home () if $game->home () > $highh;
			$lowh = $game->home () if $game->home () < $lowh;
		}	
	}
	foreach $aways ($league{$away}->aways ()) {
		foreach $game (@$aways) {
			$a += $game->away ();
			$higha = $game->away () if $game->away () > $higha;
			$lowa = $game->away () if $game->away () < $lowa;
		}
	}
	$high_home = $h - $highh;
	$high_away = $a - $higha;
	$mean_home = $high_home - $lowh;
	$mean_away = $high_away - $lowa;
	
	return {
		totals => Score->new ($h, $a),
		average => Score->new (sprintf ("%.2f",$h/6), sprintf ("%.2f",$a/6)),
		rounded => Score->new (round ($h/6), round ($a/6)),
		zero_weighted => Score->new (round ($h/6, 0), round ($a/6, 0)),
		quarter_weighted => Score->new (round ($h/6, 0.25), round ($a/6, 0.25)),
		minus_weighted => Score->new (round ($h/6, -0.5), round ($a/6, -0.5)),
		high_weighted => Score->new (round ($high_home/5), round ($high_away/5)),
		mean_weighted => Score->new (round ($mean_home/4), round ($mean_away/4)),
	};
}

sub round {
	my $number = shift;
	my $weight = shift // 0.5;

	return int ($number + $weight);
}

__PACKAGE__->meta->make_immutable;

1;
