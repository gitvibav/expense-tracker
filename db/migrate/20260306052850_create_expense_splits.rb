class CreateExpenseSplits < ActiveRecord::Migration[8.1]
  def change
    create_table :expense_splits do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :from_user, null: false, foreign_key: { to_table: :users }
      t.references :to_user, null: false, foreign_key: { to_table: :users }
      t.integer :amount_cents, null: false, default: 0

      t.timestamps
    end
  end
end
