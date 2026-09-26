class CheckoutService
  # invoca a PROCEDURE
  def self.call(user:, book:, days: 14)
    sql = ActiveRecord::Base.sanitize_sql_array([
      "CALL borrow_book_procedure(?, ?, ?);",
      user.id,
      book.id,
      days
    ])

    ActiveRecord::Base.connection.execute(sql)
    { success: true }
  rescue ActiveRecord::StatementInvalid => e
    { success: false, error: e.message[/PG::raise_exception: ERROR:\s+(.+)/, 1] || e.message }
  end
end
