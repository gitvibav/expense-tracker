require "test_helper"

class ExpenseItemTest < ActiveSupport::TestCase
  test "is valid when shares sum to item amount" do
    expense = Expense.new(payer: users(:john), tax_percent: 0, tip_percent: 0)
    item = expense.expense_items.build(description: "Food", amount_cents: 10_00)
    item.expense_item_shares.build(user: users(:john), amount_cents: 4_00)
    item.expense_item_shares.build(user: users(:anbu), amount_cents: 6_00)

    assert expense.valid?, expense.errors.full_messages.to_sentence
    assert item.valid?, item.errors.full_messages.to_sentence
  end

  test "is invalid when shares do not sum to item amount" do
    expense = Expense.new(payer: users(:john), tax_percent: 0, tip_percent: 0)
    item = expense.expense_items.build(description: "Food", amount_cents: 10_00)
    item.expense_item_shares.build(user: users(:john), amount_cents: 4_00)

    assert_not expense.valid?
    assert_includes item.errors.full_messages.join(" "), "Item shares must total"
  end
end
