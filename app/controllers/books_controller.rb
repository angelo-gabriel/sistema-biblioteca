class BooksController < ApplicationController
  def index
    # lê diretamente da VIEW
    @catalog_items = BookCatalogSummary.order(:title)
    @users = User.order(:name)
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)

    @book.available_copies = @book.total_copies if @book.total_copies.present?

    if @book.save
      redirect_to root_path, notice: "Livro '#{@book.title}' cadastrado!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :isbn, :total_copies)
  end
end
