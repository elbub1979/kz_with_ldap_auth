class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!

  add_flash_types :info, :error, :success

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end

  def after_sign_in_path_for(resource)
    home_path
  end

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_back(fallback_location: root_path)
  end
end
