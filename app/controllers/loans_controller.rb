class LoansController < ApplicationController
  def index
    # Consome a FUNCTION
    @loans = Loan.includes(:user, :book).with_late_fee.order(borrowed_at: :desc)
  end

  def create
    user = User.find(params[:user_id])
    book = Book.find(params[:book_id])

    # Invoca a STORED PROCEDURE
    result = CheckoutService.call(user: user, book: book, days: 14)

    if result[:success]
      redirect_to loans_path, notice: "Empréstimo de '#{book.title}' realizado com sucesso!"
    else
      redirect_to root_path, alert: "Erro ao emprestar: #{result[:error]}"
    end
  end

  def return_book
    loan = Loan.find(params[:id])

    Loan.transaction do
      loan.update!(returned_at: Time.current)
      loan.book.increment!(:available_copies)
    end

    redirect_to loans_path, notice: "Livro devolvido com sucesso!"
  end
end
