# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :payer, class_name: "User", inverse_of: :expenses_paid
  has_many :expense_items, dependent: :destroy
  has_many :expense_splits, dependent: :destroy

  accepts_nested_attributes_for :expense_items, allow_destroy: true

  validates :tax_percent, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :tip_percent, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def tax_percent
    self[:tax_percent].presence || 0
  end

  def tip_percent
    self[:tip_percent].presence || 0
  end

  def subtotal_paise
    # When building an expense (before persisting), sums must include in-memory items.
    return expense_items.sum { |i| i.amount_paise.to_i } if new_record? || expense_items.loaded?

    expense_items.sum(:amount_paise)
  end

  def tax_paise
    (subtotal_paise * (tax_percent.to_d / 100)).round
  end

  def tip_paise
    (subtotal_paise * (tip_percent.to_d / 100)).round
  end

  def total_paise
    subtotal_paise + tax_paise + tip_paise
  end

  def participant_ids
    expense_items.flat_map do |item|
      item.expense_item_shares.select { |s| s.amount_paise.to_i.positive? }.map(&:user_id)
    end.uniq
  end

  def participants
    User.where(id: participant_ids)
  end

  # Build expense_splits: each participant (except payer) owes their share to the payer.
  # Share = sum of their item shares + equal split of tax and tip.
  def build_splits!
    participant_totals = Hash.new(0)
    expense_items.each do |item|
      item.expense_item_shares.each do |share|
        amt = share.amount_paise.to_i
        participant_totals[share.user_id] += amt if amt.positive?
      end
    end
    participant_ids = participant_totals.keys.sort
    return if participant_ids.empty?

    n = participant_ids.size
    extras_total = tax_paise + tip_paise
    base_extra = (extras_total / n)
    remainder = (extras_total % n)

    expense_splits.destroy_all
    participant_ids.each_with_index do |user_id, idx|
      next if user_id == payer_id
      # Distribute remainder deterministically so we don't "lose" paise.
      extra = base_extra + (idx < remainder ? 1 : 0)
      total_owe = (participant_totals[user_id] || 0) + extra
      next if total_owe <= 0
      expense_splits.create!(from_user_id: user_id, to_user_id: payer_id, amount_paise: total_owe)
    end
  end
end
