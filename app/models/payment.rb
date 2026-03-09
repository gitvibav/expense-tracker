class Payment < ApplicationRecord
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user, class_name: "User"

  validates :amount_paise, presence: true, numericality: { greater_than: 0 }
  validate :cannot_pay_self

  def amount
    return 0.0 if amount_paise.nil?
    amount_paise / 100.0
  end

  def amount=(rupees)
    self.amount_paise = (rupees.to_f * 100).round
  end

  private

  def cannot_pay_self
    errors.add(:base, "Cannot make a payment to yourself") if from_user_id == to_user_id
  end
end
