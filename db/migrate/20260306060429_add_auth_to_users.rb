class AddAuthToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email, :string
    add_column :users, :password_digest, :string

    reversible do |dir|
      dir.up do
        require "bcrypt"

        # Backfill for existing users (dev/test) so we can enforce NOT NULL.
        execute <<~SQL.squish
          UPDATE users
          SET email = 'user_' || id || '@example.com'
          WHERE email IS NULL OR trim(email) = ''
        SQL

        digest = BCrypt::Password.create("password")
        execute <<~SQL.squish
          UPDATE users
          SET password_digest = '#{digest}'
          WHERE password_digest IS NULL OR trim(password_digest) = ''
        SQL

        change_column_null :users, :email, false
        change_column_null :users, :password_digest, false
      end
    end

    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
  end
end
