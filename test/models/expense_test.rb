require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  test "computes totals including tax and tip" do
    expense = Expense.new(payer: users(:john), tax_percent: 10, tip_percent: 5)
    expense.expense_items.build(description: "Dish", amount_cents: 100_00)

    assert_equal 100_00, expense.subtotal_cents
    assert_equal 10_00, expense.tax_cents
    assert_equal 5_00, expense.tip_cents
    assert_equal 115_00, expense.total_cents
  end

  test "build_splits creates per-user debts to payer" do
    john = users(:john)
    anbu = users(:anbu)
    mv = users(:michael_victor)

    expense = Expense.new(payer: john, tax_percent: 10, tip_percent: 0)
    item = expense.expense_items.build(description: "Food", amount_cents: 100_00)
    item.expense_item_shares.build(user: anbu, amount_cents: 50_00)
    item.expense_item_shares.build(user: mv, amount_cents: 50_00)
    expense.save!

    expense.build_splits!

    splits = expense.expense_splits.order(:from_user_id).to_a
    assert_equal 2, splits.size
    assert_equal [anbu.id, mv.id].sort, splits.map(&:from_user_id).sort
    assert splits.all? { |s| s.to_user_id == john.id }

    # subtotal 100.00, tax 10.00 => extras 10.00 split evenly across 2 => 5.00 each
    expected = { anbu.id => 55_00, mv.id => 55_00 }
    splits.each { |s| assert_equal expected.fetch(s.from_user_id), s.amount_cents }
  end

  test "build_splits distributes extra cents deterministically" do
    john = users(:john)
    anbu = users(:anbu)
    mv = users(:michael_victor)

    # subtotal 0.02, tax 50% => 0.01 extra cent to distribute across 2 participants
    expense = Expense.new(payer: john, tax_percent: 50, tip_percent: 0)
    item = expense.expense_items.build(description: "Candy", amount_cents: 2)
    item.expense_item_shares.build(user: anbu, amount_cents: 1)
    item.expense_item_shares.build(user: mv, amount_cents: 1)
    expense.save!

    expense.build_splits!
    splits = expense.expense_splits.order(:from_user_id).to_a

    assert_equal 2, splits.size
    extras_total = expense.tax_cents + expense.tip_cents
    assert_equal 1, extras_total

    first_participant_id = [anbu.id, mv.id].min
    first_split = splits.find { |s| s.from_user_id == first_participant_id }
    second_split = splits.find { |s| s.from_user_id != first_participant_id }

    assert_equal 2, first_split.amount_cents # 1 share + 1 extra cent
    assert_equal 1, second_split.amount_cents
  end
end
