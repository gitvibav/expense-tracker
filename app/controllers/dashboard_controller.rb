# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :require_current_user

  def index
    @total_balance_paise = current_user.balance_paise
    @total_owed_paise = current_user.total_owed_paise
    @total_due_to_me_paise = current_user.total_due_to_me_paise
    @who_owes_me = current_user.who_owes_me
    @who_i_owe = current_user.who_i_owe
    @expenses = current_user.expenses_involved
  end
end
