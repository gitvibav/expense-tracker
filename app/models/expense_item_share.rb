# frozen_string_literal: true

class ExpenseItemShare < ApplicationRecord
  belongs_to :expense_item, inverse_of: :expense_item_shares
  belongs_to :user

  attr_accessor :amount_rupees

  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sync_amount_from_rupees, if: -> { amount_rupees.present? }
  before_validation :default_amount_cents_to_zero

  def amount_rupees
    return @amount_rupees if defined?(@amount_rupees) && @amount_rupees.present?
    amount_cents.present? ? (amount_cents / 100.0).to_s : ""
  end

  def amount_rupees=(val)
    @amount_rupees = val
  end

  def sync_amount_from_rupees
    self.amount_cents = (amount_rupees.to_s.gsub(",", "").to_d * 100).round
  end

  def default_amount_cents_to_zero
    self.amount_cents = 0 if amount_cents.nil?
  end
end
