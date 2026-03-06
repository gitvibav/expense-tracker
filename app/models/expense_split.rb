# frozen_string_literal: true

class ExpenseSplit < ApplicationRecord
  belongs_to :expense
  belongs_to :from_user, class_name: "User", inverse_of: :expense_splits_as_debtor
  belongs_to :to_user, class_name: "User", inverse_of: :expense_splits_as_creditor

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
end
