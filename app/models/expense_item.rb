# frozen_string_literal: true

class ExpenseItem < ApplicationRecord
  belongs_to :expense, inverse_of: :expense_items
  has_many :expense_item_shares, dependent: :destroy

  accepts_nested_attributes_for :expense_item_shares, allow_destroy: true

  attr_accessor :amount_rupees

  validates :description, presence: true
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  validate :shares_sum_equals_amount

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

  def shares_sum_equals_amount
    return if amount_cents.nil? || amount_cents.zero?
    sum = expense_item_shares.sum { |s| s.amount_cents.to_i }
    return if sum == amount_cents
    errors.add(:base, "Item shares must total ₹#{amount_cents / 100.0}")
  end
end
