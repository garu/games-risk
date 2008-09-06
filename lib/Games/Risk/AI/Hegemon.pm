#
# This file is part of Games::Risk.
# Copyright (c) 2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU GPLv3+.
#
#

package Games::Risk::AI::Hegemon;

use 5.010;
use strict;
use warnings;

use List::Util qw{ shuffle };

use base qw{ Games::Risk::AI };

#--
# METHODS

# -- public methods

#
# my ($action, [$from, $country]) = $ai->attack;
#
# See pod in Games::Risk::AI for information on the goal of this method.
#
# This implementation never attacks anything, it ends its attack turn as soon
# as it begins. Therefore, it always returns ('attack_end', undef, undef).
#
sub attack {
    my ($self) = @_;
    my $player = $self->player;

    # find first possible attack
    my ($src, $dst);
    COUNTRY:
    foreach my $country ( shuffle $player->countries )  {
        # don't attack unless there's somehow a chance to win
        next COUNTRY if $country->armies < 4;

        NEIGHBOUR:
        foreach my $neighbour ( shuffle $country->neighbours ) {
            # don't attack ourself
            next NEIGHBOUR if $neighbour->owner eq $player;
            return ('attack', $country, $neighbour);
        }
    }

    # hum. we don't have that much choice, do we?
    return ('attack_end', undef, undef);
}


#
# my $nb = $ai->attack_move($src, $dst, $min);
#
# See pod in Games::Risk::AI for information on the goal of this method.
#
# This implementation always move the maximum possible from $src to
# $dst.
#
sub attack_move {
    my ($self, $src, $dst, $min) = @_;
    return $src->armies - 1;
}


#
# my $difficulty = $ai->difficulty;
#
# Return a difficulty level for the ai.
#
sub difficulty { return 'hard' }


#
# my @where = $ai->move_armies;
#
# See pod in Games::Risk::AI for information on the goal of this method.
#
# This implementation will not move any armies at all.
#
sub move_armies {
    my ($self) = @_;
    return;
}


#
# my @where = $ai->place_armies($nb, [$continent]);
#
# See pod in Games::Risk::AI for information on the goal of this method.
#
# This implementation will place the armies randomly on the continent owned by
# the AI, maybe restricted by $continent if it is specified.
#
sub place_armies {
    my ($self, $nb, $continent) = @_;
    my $player = $self->player;

    # FIXME: restrict to continent if strict placing
    #my @countries = defined $continent
    #    ? grep { $_->continent->id == $continent } $player->countries
    #    : $player->countries;

    # find a country that can be used as an attack base.
    my $where;
    COUNTRY:
    foreach my $country ( shuffle $player->countries )  {
        NEIGHBOUR:
        foreach my $neighbour ( shuffle $country->neighbours ) {
            # don't attack ourself
            next NEIGHBOUR if $neighbour->owner eq $player;
            $where = $country;
            last COUNTRY;
        }
    }

    # hmm, we could not find a suitable base for our next attack. 
    # FIXME: this is only true if playing with capitals, and the only
    # base suitable is our capital.
    #$where //= 

    # assign all of our armies in one country
    return ( [ $where, $nb ] );
}


# -- private methods

#
# my $descr = $ai->_description;
#
# Return a brief description of the ai and the way it operates.
#
sub _description {
    return q{

        This artificial intelligence is optimized to conquer the world.
        It checks what countries are most valuable for it, optimizes
        attacks and moves for continent bonus and blocking other
        players.

    };
}


1;

__END__



=head1 NAME

Games::Risk::AI::Hegemon - ai that tries to conquer the world



=head1 SYNOPSIS

    my $ai = Games::Risk::AI::Hegemon->new(\%params);



=head1 DESCRIPTION

This artificial intelligence is optimized to conquer the world.  It
checks what countries are most valuable for it, optimizes attacks and
moves for continent bonus and blocking other players.



=head1 METHODS

This class implements (or inherits) all of those methods (further described in
C<Games::Risk::AI>):


=over 4

=item * attack()

=item * attack_move()

=item * description()

=item * difficulty()

=item * move_armies()

=item * place_armies()

=back



=head1 SEE ALSO

L<Games::Risk::AI>, L<Games::Risk>.



=head1 AUTHOR

Jerome Quelin, C<< <jquelin at cpan.org> >>



=head1 COPYRIGHT & LICENSE

Copyright (c) 2008 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU GPLv3+.

=cut
