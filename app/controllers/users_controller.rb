# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_current_user, only: %i[index show]

  def index
    @users = User.ordered_by_name
    @total_spent_cents = Expense.includes(:expense_items).sum do |e|
      sub = e.expense_items.sum(:amount_cents)
      sub + (sub * (e.tax_percent.to_d + e.tip_percent.to_d) / 100).round
    end
  end

  def new
    @user = User.new
  end

  def create
    if current_user
      # Creating a friend: generate a temporary password. Friend can sign in and change later (not implemented yet).
      tmp_password = SecureRandom.base64(9)
      @user = User.new(friend_params.merge(password: tmp_password, password_confirmation: tmp_password))
      if @user.save
        redirect_to users_path, notice: "Friend added. Temporary password for #{@user.email}: #{tmp_password}"
      else
        @users = User.ordered_by_name
        @total_spent_cents = Expense.includes(:expense_items).sum { |e| sub = e.expense_items.sum(:amount_cents); sub + (sub * (e.tax_percent.to_d + e.tip_percent.to_d) / 100).round }
        render :index, status: :unprocessable_entity
      end
      return
    end

    @user = User.new(sign_up_params)
    if @user.save
      set_current_user(@user)
      redirect_to dashboard_path, notice: "Account created. You are signed in."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    @expenses = @user.expenses_paid.order(created_at: :desc)
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def friend_params
    params.require(:user).permit(:name, :email)
  end
end
