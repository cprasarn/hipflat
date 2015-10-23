require 'rubygems'

class DataProcessorWorker
  def perform()
    buckets = []

    # Categorize
    Building.all.each { |building|
        index = (building.distance_to_the_nearest_public_transit_station / 100).ceil
        bucket = buckets[index]
        if bucket.nil?
            bucket = Bucket.new
            bucket.bucket_id = index
            bucket.buildings = []
        end
        
        bucket.buildings << building
        buckets[index] = bucket
    }

    # Find median price
    buckets.each { | bucket |
        if bucket.nil? 
            next
        end

        median_sale = []
        median_rent = []
        bucket.buildings.each { | building |
            if !building.median_sale_price.nil?
                median_sale << building.median_sale_price
            end
            if !building.median_rent_price.nil?
                median_rent << building.median_rent_price
            end
        }

        median_sale.sort! { |a,b| a <=> b}
        sale_middle = median_sale.length / 2
        median_rent.sort! { |a,b| a <=> b}
        rent_middle = median_rent.length / 2

        bucket.median_sale_price = (0 == median_sale.length % 2) ? (median_sale[sale_middle - 1].to_f + median_sale[sale_middle].to_f) / 2 : median_sale[sale_middle]
        bucket.median_rent_price = (0 == median_rent.length % 2) ? (median_rent[rent_middle - 1].to_f + median_rent[rent_middle].to_f) / 2 : median_rent[rent_middle]

        existing = Bucket.where({bucket_id: bucket.bucket_id}).first
        if !existing.nil? 
            existing.median_sale_price = bucket.median_sale_price
            existing.median_rent_price = bucket.median_rent_price
            existing.buildings = bucket.buildings
            existing.save
        else
            bucket.save
        end
    }
  end
end
