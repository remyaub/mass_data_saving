class Intro

    def initialize(hash_to_print)
        @hash_to_print = hash_to_print
        print_intro
        print_hash(@hash_to_print)
    end

    def print_intro
        puts 
        puts "=" *60
        puts " "*15 + "SCRAPPER MAIRIES DU VAL D'OISE"
        puts "=" *60
        puts
        puts "I'am going to scrap http://annuaire-des-mairies.com/val-d-oise.html"
        puts "Key : city name"
        puts "Value : townhall email"
        puts
    end
    def print_hash(hash_to_print)
        puts "RESULT"
        puts
        @hash_to_print.each do |town_name, townhall_email|
            puts "#{town_name} : #{townhall_email}"
            puts "-" * 60
        end
        puts
        puts 'END'
    end



end



    
