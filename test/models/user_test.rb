require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "balance_cents is due_to_me minus owed" do
    john = users(:john)
    anbu = users(:anbu)

    baseline_john_due = john.total_due_to_me_cents
    baseline_john_owed = john.total_owed_cents
    baseline_anbu_due = anbu.total_due_to_me_cents
    baseline_anbu_owed = anbu.total_owed_cents

    expense = Expense.new(payer: john, tax_percent: 0, tip_percent: 0)
    item = expense.expense_items.build(description: "Meal", amount_cents: 100_00)
    item.expense_item_shares.build(user: anbu, amount_cents: 100_00)
    expense.save!
    expense.build_splits!

    assert_equal baseline_john_due + 100_00, john.total_due_to_me_cents
    assert_equal baseline_john_owed, john.total_owed_cents
    assert_equal john.total_due_to_me_cents - john.total_owed_cents, john.balance_cents

    assert_equal baseline_anbu_due, anbu.total_due_to_me_cents
    assert_equal baseline_anbu_owed + 100_00, anbu.total_owed_cents
    assert_equal anbu.total_due_to_me_cents - anbu.total_owed_cents, anbu.balance_cents
  end
end
