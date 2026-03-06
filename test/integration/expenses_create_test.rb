require "test_helper"

class ExpensesCreateTest < ActionDispatch::IntegrationTest
  test "can create an itemized expense via nested params and it creates splits" do
    john = users(:john)
    anbu = users(:anbu)
    mv = users(:michael_victor)

    # Sign in
    post session_path, params: { email: john.email, password: "password" }
    assert_response :redirect

    assert_difference -> { Expense.count }, +1 do
      post expenses_path, params: {
        expense: {
          tax_percent: "0",
          tip_percent: "0",
          # Intentionally use a single-item, non-indexed hash to ensure controller normalization works.
          expense_items_attributes: {
            description: "Food",
            amount_rupees: "100",
            expense_item_shares_attributes: {
              "0" => { user_id: anbu.id.to_s, amount_rupees: "40" },
              "1" => { user_id: mv.id.to_s, amount_rupees: "60" }
            }
          }
        }
      }
    end

    expense = Expense.order(:id).last
    expense.build_splits! if expense.expense_splits.none?

    splits = expense.expense_splits.order(:from_user_id).to_a
    assert_equal 2, splits.size
    assert_equal [anbu.id, mv.id].sort, splits.map(&:from_user_id).sort
    assert splits.all? { |s| s.to_user_id == john.id }

    expected = { anbu.id => 40_00, mv.id => 60_00 }
    splits.each { |s| assert_equal expected.fetch(s.from_user_id), s.amount_cents }
  end
end

