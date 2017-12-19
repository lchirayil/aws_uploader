class Bucket < ApplicationRecord
  include PgSearch
  pg_search_scope :search_for, :against => :filename
end
