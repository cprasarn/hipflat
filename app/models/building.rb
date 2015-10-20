class Building
  include Mongoid::Document
  field :name, type: String
  field :median_sale_price, type: Float
  field :median_rent_price, type: Float
  field :nearest_public_transit_station, type: String
  field :distance_to_the_nearest_public_transit_station, type: Float
end
