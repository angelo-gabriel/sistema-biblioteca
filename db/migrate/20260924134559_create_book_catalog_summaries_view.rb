class CreateBookCatalogSummariesView < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      CREATE VIEW book_catalog_summaries AS
      SELECT
        b.id AS book_id,
        b.title,
        b.author,
        b.isbn,
        b.available_copies,
        b.total_copies,
        COUNT(l.id) AS total_borrows,
        CASE
          WHEN b.available_copies > 0 THEN 'Disponível'
          ELSE 'Esgotado'
        END AS availability_status
      FROM books b
      LEFT JOIN loans l ON l.book_id = b.id
      GROUP BY b.id;
    SQL
  end

  def down
    execute "DROP VIEW IF EXISTS book_catalog_summaries;"
  end
end
