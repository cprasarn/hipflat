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
            bucket.bucket_id = index + 1
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

        total_sale = 0.0
        total_sale_counter = 0
        total_rent = 0.0
        total_rent_counter = 0
        bucket.buildings.each { | building |
            if !building.median_sale_price.nil?
                total_sale += building.median_sale_price
                total_sale_counter += 1;
            end
            if !building.median_rent_price.nil?
                total_rent += building.median_rent_price
                total_rent_counter += 1;
            end
        }

        bucket.median_sale_price = total_sale / total_sale_counter
        bucket.median_rent_price = total_rent / total_rent_counter

        existing = Bucket.where({bucket_id: bucket.bucket_id}).first
        if !existing.nil? 
            existing.median_sale_price = bucket.median_sale_price
            existing.median_rent_price = bucket.median_rent_price
            existing.buildings = bucket.buildings
        else
            bucket.save
        end
    }
  end
end
