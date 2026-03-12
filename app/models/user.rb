# frozen_string_literal: true

class User < ApplicationRecord
  has_many :expenses_paid, class_name: "Expense", foreign_key: :payer_id, inverse_of: :payer, dependent: :destroy
  has_many :expense_item_shares, dependent: :destroy
  has_many :expense_splits_as_debtor, class_name: "ExpenseSplit", foreign_key: :from_user_id, inverse_of: :from_user, dependent: :destroy
  has_many :expense_splits_as_creditor, class_name: "ExpenseSplit", foreign_key: :to_user_id, inverse_of: :to_user, dependent: :destroy
  has_many :payments_made, class_name: "Payment", foreign_key: :from_user_id, inverse_of: :from_user, dependent: :destroy
  has_many :payments_received, class_name: "Payment", foreign_key: :to_user_id, inverse_of: :to_user, dependent: :destroy

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: :friend_id, dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  has_secure_password

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  before_validation :normalize_email

  scope :excluding_user, ->(user) { where.not(id: user) }
  scope :ordered_by_name, -> { order(:name) }

  def all_friends
    friends.where(friendships: { status: "accepted" }) +
    inverse_friends.where(friendships: { status: "accepted" })
  end

  def friends_with?(user)
    Friendship.between(self, user).where(status: "accepted").exists?
  end

  # Expenses where this user paid or has a non-zero share (for "my expenses" list)
  def expenses_involved
    ids_from_shares = ExpenseItemShare.joins(:expense_item)
      .where(user_id: id)
      .where("expense_item_shares.amount_paise > 0")
      .select(:expense_id).distinct
    Expense.where(payer_id: id).or(Expense.where(id: ids_from_shares)).distinct.order(created_at: :desc)
  end

  # Total amount this user owes to others (sum of splits where from_user = self) minus payments made
  def total_owed_paise
    expense_splits_as_debtor.sum(:amount_paise) - payments_made.sum(:amount_paise)
  end

  # Total amount others owe this user (sum of splits where to_user = self) minus payments received
  def total_due_to_me_paise
    expense_splits_as_creditor.sum(:amount_paise) - payments_received.sum(:amount_paise)
  end

  # Balance: positive = others owe you, negative = you owe others
  def balance_paise
    total_due_to_me_paise - total_owed_paise
  end

  # Who owes this user and how much (user => amount_paise) after accounting for payments
  def who_owes_me
    debt_owed = expense_splits_as_creditor
      .joins(:from_user)
      .group("users.id")
      .sum(:amount_paise)

    payments_received_by_user = payments_received
      .joins(:from_user)
      .group("users.id")
      .sum(:amount_paise)

    result = {}
    (debt_owed.keys + payments_received_by_user.keys).uniq.each do |user_id|
      owed = debt_owed[user_id] || 0
      paid = payments_received_by_user[user_id] || 0
      net_amount = owed - paid
      result[user_id] = net_amount if net_amount > 0
    end

    result.transform_keys { |user_id| User.find(user_id) }
  end

  # Who this user owes and how much (user => amount_paise) after accounting for payments
  def who_i_owe
    debt_owing = expense_splits_as_debtor
      .joins(:to_user)
      .group("users.id")
      .sum(:amount_paise)

    payments_made_to_user = payments_made
      .joins(:to_user)
      .group("users.id")
      .sum(:amount_paise)

    result = {}
    (debt_owing.keys + payments_made_to_user.keys).uniq.each do |user_id|
      owing = debt_owing[user_id] || 0
      paid = payments_made_to_user[user_id] || 0
      net_amount = owing - paid
      result[user_id] = net_amount if net_amount > 0
    end

    result.transform_keys { |user_id| User.find(user_id) }
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
