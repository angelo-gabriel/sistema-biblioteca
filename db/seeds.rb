puts "Limpando banco de dados..."
Loan.destroy_all()
Book.destroy_all()
User.destroy_all()

puts "Cadastrando leitores..."
users = User.create!([
  { name: "Ângelo Gabriel", email: "angelo@exemplo.com" },
  { name: "Lucas Rodrigues", email: "lucas@exemplo.com" },
  { name: "Carlos Drummond", email: "carlos@exemplo.com" },
  { name: "John Doe", email: "john@exemplo.com" }
])

puts "Cadastrando livros..."
books = Book.create!([
  {
    title: "Dom Casmurro",
    author: "Machado de Assis",
    isbn: "9788535914849",
    total_copies: 3,
    available_copies: 2
  },
  {
    title: "Moby Dick",
    author: "Herman Melville",
    isbn: "9788535911237",
    total_copies: 2,
    available_copies: 1
  },
  {
    title: "1984",
    author: "George Orwell",
    isbn: "9788535909555",
    total_copies: 1,
    available_copies: 0
  },
  {
    title: "O Cortiço",
    author: "Aluísio Azevedo",
    isbn: "9788520922880",
    total_copies: 2,
    available_copies: 2
  },
  {
    title: "Orgulho e Preconceito",
    author: "Jane Austen",
    isbn: "9788535918847",
    total_copies: 2,
    available_copies: 2
  }
])

puts "Criando histórico de empréstimos..."

# Empréstimo ativo em dia
Loan.create!(
  user: users[0],
  book: books[1],
  borrowed_at: 3.days.ago,
  due_date: 11.days.from_now.to_date,
  returned_at: nil
)

# Empréstimo ativo em atraso
Loan.create!(
  user: users[2],
  book: books[0],
  borrowed_at: 19.days.ago,
  due_date: 5.days.ago.to_date,
  returned_at: nil
)

# Empréstimo ativo em atraso crítico
Loan.create!(
  user: users[1],
  book: books[2],
  borrowed_at: 24.days.ago,
  due_date: 10.days.ago.to_date,
  returned_at: nil
)

# Empréstimo já devolvido
Loan.create!(
  user: users[3],
  book: books[4],
  borrowed_at: 24.days.ago,
  due_date: 16.days.ago.to_date,
  returned_at: 18.days.ago
)

puts "Seeds carregadas com sucesso!"
