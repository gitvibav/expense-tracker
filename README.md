# Expense Tracker (Splitwise-style)

Track shared expenses with friends using an itemized bill flow (similar to Splitwise).

### What you can do

- **Add users/friends** (any number)
- **Share an itemized expense**
  - Add one or more items
  - Assign each item to one person or split it across multiple people
  - Add **tax %** and **tip %** (applied to subtotal and split equally among participants)
- **Settle up payments**
  - Record payments made to friends you owe
  - Enter amount in rupees (e.g., 28.17 for ₹28.17)
  - Add optional notes about the payment
  - Payments automatically update balances for both users
- **See your dashboard**
  - **Total balance** = (total due to you) − (total you owe)
  - Lists of who you owe and who owes you (after accounting for payments)
  - List of your expenses
  - "Settle Up" button when you owe money to friends
- **See a friend’s expenses** (expenses they paid)

### Pages

- **Dashboard**: `/` or `/dashboard`
- **Share expense**: `/share`
- **Settle up**: `/payments/new`
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
7. When you owe money, click **"Settle Up"** to record payments to friends
   - Select who you're paying from the dropdown (shows amount owed)
   - Enter payment amount in rupees
   - Add optional notes
   - Click **"Record Payment"** to update both users' balances

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
- **Payments** are recorded in rupees but stored as cents for consistency.
- Balances automatically account for both expense splits and payments made/received.
