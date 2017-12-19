class Bucket < ApplicationRecord
  include PgSearch
  pg_search_scope :kinda_spelled_like, :against => :filename, :using => { :tsearch => {:prefix => true, :dictionary => "english"} }
end
