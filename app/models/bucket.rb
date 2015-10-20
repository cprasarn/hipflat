class Bucket
  include Mongoid::Document
  field :bucket_id, type: Integer
  field :median_sale_price, type: Float
  field :median_rent_price, type: Float
  embeds_many :buildings
end
