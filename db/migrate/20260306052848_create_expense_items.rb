class CreateExpenseItems < ActiveRecord::Migration[8.1]
  def change
    create_table :expense_items do |t|
      t.references :expense, null: false, foreign_key: true
      t.string :description
      t.integer :amount_cents, null: false, default: 0

      t.timestamps
    end
  end
end
