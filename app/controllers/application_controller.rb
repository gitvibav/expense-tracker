class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  private

  def current_user
    return nil unless session[:current_user_id]
    @current_user ||= User.find_by(id: session[:current_user_id])
  end

  def set_current_user(user)
    session[:current_user_id] = user.id
  end

  def require_current_user
    return if current_user
    redirect_to new_session_path, alert: "Please sign in."
  end
end
