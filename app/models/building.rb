class Building
  include Mongoid::Document
  field :name, type: String
  field :median_sale_price, type: Integer
  field :median_rent_price, type: Integer
  field :nearest, type: String
  field :distance, type: Integer
end
