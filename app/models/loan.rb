class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :book

  # retorna com o cálculo de multa via FUNCTION
  scope :with_late_fee, -> {
    select(
      "loans.*",
      "calculate_late_fee(loans.due_date, loans.returned_at) AS current_late_fee"
    )
  }

  # método para consultar a multa
  def calculated_late_fee
    query = ActiveRecord::Base.sanitize_sql_array([
      "SELECT calculate_late_fee(?, ?)",
      due_date,
      returned_at
    ])
    ActiveRecord::Base.connection.select_value(query).to_f
  end
end
