# Expense Tracker (Splitwise-style)

Track shared expenses with friends using an itemized bill flow (similar to Splitwise).

### What you can do

- **Add users/friends** (any number)
- **Share an itemized expense**
  - Add one or more items
  - Assign each item to one person or split it across multiple people
  - Add **tax %** and **tip %** (applied to subtotal and split equally among participants)
- **See your dashboard**
  - **Total balance** = (total due to you) − (total you owe)
  - Lists of who you owe and who owes you
  - List of your expenses
- **See a friend’s expenses** (expenses they paid)

### Pages

- **Dashboard**: `/` or `/dashboard`
- **Share expense**: `/share`
- **Friends**: `/users`
- **Friend detail**: `/users/:id`

### Tech

- Ruby / Rails (Rails 8)
- PostgreSQL (development + test + production)
- Hotwire (Turbo + Stimulus)
- Solid Cache, Solid Queue, Solid Cable (for production)

### Setup

**Prerequisites:**
- PostgreSQL (installed and running)

Install gems:

```bash
bundle install
```

Set up database configuration (optional - defaults are provided):
```bash
export DATABASE_USERNAME=your_username
export DATABASE_PASSWORD=your_password
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
```

Create the database and seed sample users:

```bash
bin/rails db:drop db:create db:migrate db:seed
```

Run the app:

```bash
bin/rails server
```

### How to use

1. **Sign up** (`/sign_up`) or **Sign in** (`/session/new`)
2. Go to **Friends** (`/users`) to add friends (each friend is also a login account)
3. Go to **Share expense** (`/share`)
4. Enter item amount and make sure the **sum of shares equals the item amount**
5. Click **Done**
6. View **Dashboard** (`/dashboard`) for balances and your expenses

### Default seeded accounts (development)

After running `bin/rails db:seed`, you can sign in with:

- `john@example.com` / `password`
- `anbu@example.com` / `password`
- `michael.victor@example.com` / `password`

### Running tests

```bash
bin/rails test
```

### Notes on calculations

- Money is stored as integer **cents** (`amount_cents`).
- Form inputs accept ₹ values (decimals) and convert to cents.
- **Tax** and **tip** are computed from the subtotal, rounded to cents.
- Tax + tip cents are split equally among participants; any remainder cents are distributed deterministically.
