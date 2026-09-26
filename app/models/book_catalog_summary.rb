class BookCatalogSummary < ApplicationRecord
  self.table_name = "book_catalog_summaries"
  self.primary_key = "book_id"

  def readonly?
    true
  end

  belongs_to :book, foreign_key: "book_id"
end
