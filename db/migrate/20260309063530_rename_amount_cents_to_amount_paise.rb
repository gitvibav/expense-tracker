class RenameAmountCentsToAmountPaise < ActiveRecord::Migration[8.1]
  def change
    rename_column :expense_items, :amount_cents, :amount_paise
    rename_column :expense_item_shares, :amount_cents, :amount_paise
    rename_column :expense_splits, :amount_cents, :amount_paise
    rename_column :payments, :amount_cents, :amount_paise
  end
end
