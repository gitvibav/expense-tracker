class PaymentsController < ApplicationController
  before_action :require_current_user

  def new
    @users_i_owe = current_user.who_i_owe.map do |user, amount_paise|
      [ "#{user.name} (Rs. #{(amount_paise / 100.0).round(2)})", user.id ]
    end
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.from_user = current_user

    # Convert amount from rupees to paise
    if params[:payment][:amount].present?
      @payment.amount = params[:payment][:amount]
    end

    if @payment.save
      redirect_to dashboard_path, notice: "Payment recorded successfully!"
    else
      @users_i_owe = current_user.who_i_owe.map do |user, amount_paise|
        [ "#{user.name} (Rs. #{(amount_paise / 100.0).round(2)})", user.id ]
      end
      flash.now[:alert] = "Payment could not be recorded: #{@payment.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:to_user_id, :amount, :notes)
  end
end
