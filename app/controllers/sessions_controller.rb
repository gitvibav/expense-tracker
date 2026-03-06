# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if current_user
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password].to_s)
      set_current_user(user)
      redirect_to dashboard_path, notice: "Welcome back, #{user.name}."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:current_user_id] = nil
    redirect_to new_session_path, notice: "Signed out."
  end
end

