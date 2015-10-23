require 'rubygems'
require 'mechanize'

class DataScraperWorker
  def perform()
    m = Mechanize.new
    page = m.get('http://hipflat.github.io/')
    html = Nokogiri::HTML(page.body)
    html.css('table.building tbody').each {|b|
      building = nil

      b.css('tr').each { |r|
          field = r.css('th').text
          value = r.css('td').text.strip
          field_name = field.gsub(/ /, "_").downcase
          if "name" == field_name
            building = Building.where(name: value).first
            if building.nil?
              building = Building.new
              building.name = value
            end
          else
            field_value = case field_name
              when "median_sale_price", "median_rent_price", "distance_to_the_nearest_public_transit_station"
                value.delete(',').to_f
              else
                value
            end
            building[field_name] = field_value
          end
      }

      building.save
    }
  end
end
