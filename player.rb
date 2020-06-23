#!/bin/ruby

class Player
    @@list = []
    @@dealer
    @@eldest_hand
    @@leader
    @@follower
    @@winner
    @@loser

    def self.winner=(player)
        @@winner = player
    end

    def self.loser=(player)
        @@loser = player
    end

    def self.leader()
        @@leader
    end

    def self.follower()
        @@follower
    end

    def self.list()
        @@list
    end

    def self.set_dealer(player)
        @@dealer = player
    end

    def self.dealer()
        @@dealer
    end

    def self.set_eldest_hand(player)
        @@eldest_hand = player
    end

    def self.eldest_hand()
        @@eldest_hand
    end

    def self.new_hand()
        self.list.each do |player|
            player.draw(5)
        end
    end

    def self.score()
        Player.list.each do |player|
            puts "#{player.name} is at #{player.score}"
        end
    end
    attr_accessor :name, :score, :hand, :vulnerable, :tricks
    def initialize(name)
        @name = name
        @vulnerable = false
        @score = 0
        @tricks = 0
        @hand = []
        @@list.push(self)
    end

    def set_vulnerable=(bool)
        @vulnerable = bool
    end

    def vulnerable?()
        @vulnerable
    end

    def hand()
        @hand
    end

    def show_hand()
        puts "#{self.name}'s hand\n"
        number = 0
        @hand.each do |card|
            puts "#{number}. #{@hand[number].name}"
            number += 1
        end
        puts
    end

    def draw(number)
        number.times do
            @hand.push(Cards.deck.delete_at(1))
        end
    end

    def pick_card()
        self.show_hand
        1.times do
            print "Which card would you like to play? "
            card = gets.to_i
            if card > @hand.count - 1 # -1, else it allows you to select 5, which doesn't work the way you want when counting from 0.
                redo
            end
            puts

            puts "\Playing #{@hand[card].name}\n"
            puts
            return @hand.delete_at(card)
        end
    end

    def self.play()
        Player.list.each do |player|
            player.tricks = 0
        end

        tricks = 1
        @@leader = @@eldest_hand
        @@follower = @@dealer

        until tricks == 6
            puts "#{@@leader.name} leads.\n\n"
            leader_card = @@leader.lead()
            follower_card = @@follower.follow(leader_card)
            winner = Cards.winner(leader_card, follower_card)

            if leader_card != winner
                puts "#{@@follower.name} won.\n"
                @@follower.tricks += 1

                temp = @@leader
                @@leader = @@follower
                @@follower = temp
            else
                puts "#{@@leader.name} won.\n"
                @@leader.tricks += 1
            end

            tricks += 1
        end
    end

    def lead()
        card = self.pick_card()
        sleep(1)
        return card
    end

    def follow(leader_card)
        force_follow_suit = false
        @hand.each do |card|
            if card.suit == leader_card.suit
                force_follow_suit = true
            end
        end

        1.times do
            follower_card = self.pick_card()

            if force_follow_suit && follower_card.suit != leader_card.suit
                puts "Please follow suit."
                @hand.push(follower_card)
                puts
                sleep(1)
                redo
            end
            # I'd love to take from here til the end out of the 1.times block, but then local variables break.
            puts "\Playing #{follower_card.name}\n"
            puts
            sleep(1)
            @hand.delete(follower_card)
            return follower_card
            #for some reason, just having "return @hand.delete(follower_card)" returns a nil value. not sure why.
        end
    end

    def discard?()
        self.show_hand()
        return Game.yesno?("Would you like to discard and redraw? ")
    end

    def redraw(number)
        1.times do
            if number == nil
                self.show_hand()
                number = Game.input_number("How many cards would you like to redraw? ")
                puts
            end

            if number > Cards.deck.count
                puts "There aren't enough cards for that. Choose a different number, please.\n"
                number = nil
                redo
            end
        end

        i = 0
        number.times do
            1.times do
                self.show_hand()
                print "Which card would you like to discard?(#{i}/#{number}) "
                card = self.pick_card()
                puts "\nDiscarding #{@hand.delete_at(card).name}\n"
                sleep(1)
                puts
                i += 1
            end
        end
        puts
        self.draw(number)
    end

    def permission?(number)
        return Game.yesno?("Will you allow your opponent to discard #{number} cards? ")
    end


    def self.declare_score()
        if @@dealer.tricks > @@eldest_hand.tricks 
            @@winner = @@dealer and @@loser = @@eldest_hand 
        else
            @@winner = @@eldest_hand and @@loser = @@dealer
        end
        puts "#{@@winner.name} got #{@@winner.tricks}!"

        @@winner.score += 1

        if @@loser.vulnerable?
            @@winner.score += 1
        end

        if @@winner.tricks == 5
            @@winner.score += 1
        end
            
        Player.score
    end

end
