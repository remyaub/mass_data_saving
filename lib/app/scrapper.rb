require 'nokogiri'
require 'open-uri'
require 'pry'
require 'json'
require_relative 'view'


   
class ValdOiseScrapper
    
    attr_accessor :page

    def initialize
        @page = "http://annuaire-des-mairies.com/val-d-oise.html" 
        Intro.new(self.all_mails)
    end


    def get_townhall_urls(nokogiri_page)                                    #recupere les urls et les mets dans un tableau.
        towns_urls_array = [] 
        urls = nokogiri_page.xpath('//a[@class="lientxt"]/@href') 
        urls.each do |url|
        towns_urls_array << "http://annuaire-des-mairies.com#{url}" 
        end
        return towns_urls_array
    end


    def get_email_from(town_url_string)                                     #recupere les emails
        town_page = Nokogiri::HTML(open(town_url_string)) 
        town_email = town_page.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]')
        if town_email.text == ""
            town_email_string = "Sorry, email not found..."
        else
            town_email_string = town_email.text
        end
        return town_email_string
    end


    def townhall_name                                                       #recupere le nom de la ville
        town_page = Nokogiri::HTML(open(@page))
        name = town_page.xpath('//a[@class="lientxt"]/text()') 
        return name.to_a
    end


    def all_mails                                                            #boucle qui permet d'aller chercher l'email sur chaque URL, recupère les nom de ville de la methode town_name et les retourné dans un hash
        nokogiri_page =  Nokogiri::HTML(open(@page))
        town_names_array = self.townhall_name
        email_from_city_name_hash = {}

        self.get_townhall_urls(nokogiri_page).zip(town_names_array).each do |town_url, town_name| 
            email_from_city_name_hash[town_name.to_s.to_sym] = self.get_email_from(town_url)
        end

        return email_from_city_name_hash
    end


    def save_as_json(convert_to_json)                                       #conversion fichier json
        File.open("db/scrapper.json","w") do |f|
        f.write(convert_to_json)
        end
    end

    def save_as_csv(convert_to_csv)                                         #conversion fichier csv
        CSV.open("db/scrapper.csv", "w") do |csv|
            csv << [convert_to_csv]
        end
    end

    def save_as_spreadsheet(convert_to_gg)                                  #export google speadsheet 
        session = GoogleDrive::Session.from_config("config.json")
        townhalls_spreadsheet = session.spreadsheet_by_key("1rYaWs-PDVoLy7eJ027fXpD-ImqG3IG_eY2kL6idhgAQ").worksheets[0]
        townhalls_spreadsheet[1, 1] = "townhall_name"
        townhalls_spreadsheet[1, 2] = "town_hall_email"
        i = 2
        convert_to_gg.each do |hash|
            townhalls_spreadsheet[i, 1] = hash[0]
            townhalls_spreadsheet[i, 2] = hash[1]
            i += 1
        end   
        townhalls_spreadsheet.save 
    end

    def perform
        # save_as_json(all_mails)
        # save_as_csv(all_mails)
        save_as_spreadsheet(all_mails)
    end

end