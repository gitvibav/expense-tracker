# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    return unless current_user
    @total_balance_cents = current_user.balance_cents
    @total_owed_cents = current_user.total_owed_cents
    @total_due_to_me_cents = current_user.total_due_to_me_cents
    @who_owes_me = current_user.who_owes_me
    @who_i_owe = current_user.who_i_owe
    @expenses = current_user.expenses_involved
  end
end
