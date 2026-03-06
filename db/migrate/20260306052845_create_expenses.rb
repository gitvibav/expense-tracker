class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :payer, null: false, foreign_key: { to_table: :users }
      t.decimal :tax_percent, default: 0, precision: 5, scale: 2
      t.decimal :tip_percent, default: 0, precision: 5, scale: 2
      t.string :description

      t.timestamps
    end
  end
end
