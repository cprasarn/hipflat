require 'rubygems'
require 'mechanize'

class DataScraperWorker
  include Sidekiq::Worker
  def perform()
    m = Mechanize.new
    page = m.get('http://hipflat.github.io/')
    html = Nokogiri::HTML(page.body)
    html.css('table.building tbody').each {|b|
      rows = b.css('tr')
      name = rows[0].css('td').text.strip
      if 5 == rows.length
        median_sale_price = rows[1].css('td').text.strip.to_i
        median_rent_price = rows[2].css('td').text.strip.to_i
        nearest = rows[3].css('td').text.strip
        distance = rows[4].css('td').text.to_i
      else
        nearest = rows[1].css('td').text.strip
        distance = rows[2].css('td').text.to_i
      end

      building = Building.where(name: name)
      if building.blank?
        building = Building.new
        building.name = name
        if 5 == rows.length
          building.median_sale_price = median_sale_price
          building.median_rent_price = median_rent_price
        end
        building.nearest = nearest
        building.distance = distance
        building.save
      end
    }
  end
end
