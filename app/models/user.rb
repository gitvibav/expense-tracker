# frozen_string_literal: true

class User < ApplicationRecord
  has_many :expenses_paid, class_name: "Expense", foreign_key: :payer_id, inverse_of: :payer, dependent: :destroy
  has_many :expense_item_shares, dependent: :destroy
  has_many :expense_splits_as_debtor, class_name: "ExpenseSplit", foreign_key: :from_user_id, inverse_of: :from_user, dependent: :destroy
  has_many :expense_splits_as_creditor, class_name: "ExpenseSplit", foreign_key: :to_user_id, inverse_of: :to_user, dependent: :destroy

  has_secure_password

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  before_validation :normalize_email

  scope :excluding_user, ->(user) { where.not(id: user) }
  scope :ordered_by_name, -> { order(:name) }

  # Expenses where this user paid or has a share (for "my expenses" list)
  def expenses_involved
    ids_from_shares = ExpenseItemShare.joins(:expense_item).where(user_id: id).select(:expense_id).distinct
    Expense.where(payer_id: id).or(Expense.where(id: ids_from_shares)).distinct.order(created_at: :desc)
  end

  # Total amount this user owes to others (sum of splits where from_user = self)
  def total_owed_cents
    expense_splits_as_debtor.sum(:amount_cents)
  end

  # Total amount others owe this user (sum of splits where to_user = self)
  def total_due_to_me_cents
    expense_splits_as_creditor.sum(:amount_cents)
  end

  # Balance: positive = others owe you, negative = you owe others
  def balance_cents
    total_due_to_me_cents - total_owed_cents
  end

  # Who owes this user and how much (user => amount_cents)
  def who_owes_me
    expense_splits_as_creditor
      .joins(:from_user)
      .group("users.id")
      .sum(:amount_cents)
      .transform_keys { |user_id| User.find(user_id) }
  end

  # Who this user owes and how much (user => amount_cents)
  def who_i_owe
    expense_splits_as_debtor
      .joins(:to_user)
      .group("users.id")
      .sum(:amount_cents)
      .transform_keys { |user_id| User.find(user_id) }
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
