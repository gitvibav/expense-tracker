# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_current_user, only: %i[index show]

  def index
    @users = current_user ? current_user.all_friends : User.ordered_by_name
    if current_user
      @total_spent_paise = current_user.expenses_involved.sum do |e|
        sub = e.expense_items.sum(:amount_paise)
        sub + (sub * (e.tax_percent.to_d + e.tip_percent.to_d) / 100).round
      end
    else
      @total_spent_paise = 0
    end
  end

  def new
    @user = User.new
  end

  def create
    if current_user
      # Find existing user to add as friend
      @user = User.find_by(email: friend_params[:email])

      if @user.nil?
        @users = current_user.all_friends
        @total_spent_paise = current_user.expenses_involved.sum do |e|
          sub = e.expense_items.sum(:amount_paise)
          sub + (sub * (e.tax_percent.to_d + e.tip_percent.to_d) / 100).round
        end
        flash.now[:alert] = "User not found. Please check email address."
        render :index, status: :unprocessable_entity
        return
      end

      # Check if trying to add self as friend
      if @user.id == current_user.id
        @users = current_user.all_friends
        @total_spent_paise = current_user.expenses_involved.sum do |e|
          sub = e.expense_items.sum(:amount_paise)
          sub + (sub * (e.tax_percent.to_d + e.tip_percent.to_d) / 100).round
        end
        flash.now[:alert] = "You cannot add yourself as a friend."
        render :index, status: :unprocessable_entity
        return
      end

      # Check if already friends
      if current_user.friends_with?(@user)
        @users = current_user.all_friends
        @total_spent_paise = current_user.expenses_involved.sum do |e|
          sub = e.expense_items.sum(:amount_paise)
          sub + (sub * (e.tax_percent.to_d + e.tip_percent.to_d) / 100).round
        end
        flash.now[:alert] = "You are already friends with #{@user.name}."
        render :index, status: :unprocessable_entity
        return
      end

      # Create friendship relationship
      Friendship.create!(user: current_user, friend: @user, status: "accepted")
      redirect_to users_path, notice: "#{@user.name} added as friend!"
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
    params.require(:user).permit(:email)
  end
end
