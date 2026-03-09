class Payment < ApplicationRecord
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user, class_name: "User"

  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validate :cannot_pay_self

  def amount
    return 0.0 if amount_cents.nil?
    amount_cents / 100.0
  end

  def amount=(dollars)
    self.amount_cents = (dollars.to_f * 100).round
  end

  private

  def cannot_pay_self
    errors.add(:base, "Cannot make a payment to yourself") if from_user_id == to_user_id
  end
end
