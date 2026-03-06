class CreateExpenseItemShares < ActiveRecord::Migration[8.1]
  def change
    create_table :expense_item_shares do |t|
      t.references :expense_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :amount_cents, null: false, default: 0

      t.timestamps
    end
  end
end
