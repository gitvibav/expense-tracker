# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :require_current_user, only: %i[new create]

  def new
    if User.none?
      redirect_to sign_up_path, alert: "Create an account first."
      return
    end
    @users = User.ordered_by_name
    @expense = Expense.new(payer_id: current_user.id, tax_percent: 6.5, tip_percent: 18)
    items_count = params[:items].to_i.clamp(1, 50)
    items_count.times { build_item_with_shares }
  end

  def create
    filtered_params = expense_params
    filter_blank_items!(filtered_params)
    @expense = Expense.new(filtered_params)
    @expense.payer_id = current_user.id
    if @expense.save
      @expense.build_splits!
      redirect_to dashboard_path, notice: "Expense was successfully added."
    else
      @users = User.ordered_by_name
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @expense = Expense.find(params[:id])
  end

  private

  def expense_params
    params.require(:expense).permit(
      :tax_percent, :tip_percent, :description,
      expense_items_attributes: [
        :id, :description, :amount_cents, :amount_rupees, :_destroy,
        { expense_item_shares_attributes: %i[id user_id amount_cents amount_rupees _destroy] }
      ]
    )
  end

  def build_item_with_shares
    item = @expense.expense_items.build
    @users.each { |u| item.expense_item_shares.build(user: u, amount_cents: 0) }
  end

  def filter_blank_items!(params_hash)
    items = params_hash[:expense_items_attributes].to_h
    # Rails sometimes sends a single nested record without the usual numeric index keys.
    # Normalizing here keeps the create path stable and prevents "last value wins" overwrites.
    items = { "0" => items } if items.key?("description") || items.key?(:description)
    params_hash[:expense_items_attributes] = items.each_with_object({}) do |(idx, attrs), result|
      next unless attrs.is_a?(Hash)
      attrs = attrs.to_unsafe_h if attrs.respond_to?(:to_unsafe_h)
      attrs = attrs.stringify_keys if attrs.respond_to?(:stringify_keys)
      desc = (attrs["description"] || attrs[:description]).to_s.strip
      amt = (attrs["amount_cents"] || attrs[:amount_cents]).to_s.to_i
      amt_rupees = (attrs["amount_rupees"] || attrs[:amount_rupees]).to_s.strip
      next if desc.blank? || (amt.zero? && amt_rupees.blank?)
      # Normalize expense_item_shares_attributes if submitted without index
      shares = attrs["expense_item_shares_attributes"] || attrs[:expense_item_shares_attributes]
      if shares.is_a?(Hash) && (shares.key?("user_id") || shares.key?(:user_id))
        attrs = attrs.merge("expense_item_shares_attributes" => { "0" => shares })
      end
      result[idx] = attrs
    end
  end
end
