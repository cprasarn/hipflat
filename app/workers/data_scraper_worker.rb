require 'rubygems'
require 'mechanize'

class DataScraperWorker
  def perform()
    m = Mechanize.new
    page = m.get('http://hipflat.github.io/')
    html = Nokogiri::HTML(page.body)
    html.css('table.building tbody').each {|b|
      rows = b.css('tr')
      name = rows[0].css('td').text.strip

      building = Building.where(name: name).first
      if building.blank?
        building = Building.new
        building.name = name
      end

      if 3 == rows.length
        nearest = rows[1].css('td').text.strip
        distance = rows[2].css('td').text.to_f
      elsif 4 == rows.length
        field = rows[1].css('th').text
        value = rows[1].css('td').text.strip
        field_name = field.gsub(/ /, "_").downcase
        if "median_sale_price" == field_name
          building.median_sale_price = value.to_f
        elsif "median_rent_price" == field_name
          building.median_rent_price = value.to_f
        end
        nearest = rows[2].css('td').text.strip
        distance = rows[3].css('td').text.to_f
      else 
        building.median_sale_price = rows[1].css('td').text.strip.to_f
        building.median_rent_price = rows[2].css('td').text.strip.to_f
        nearest = rows[3].css('td').text.strip
        distance = rows[4].css('td').text.to_f
      end

      building.nearest_public_transit_station = nearest
      building.distance_to_the_nearest_public_transit_station = distance
      building.save
    }
  end
end
