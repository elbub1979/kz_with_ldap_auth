class ApplicationController < ActionController::Base
  include Pundit

  before_action :authorized?

  before_action :authenticate_user!

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end

  def after_sign_in_path_for(resource)
    home_path
  end

  private

  def authorized?
    return if current_user.has_role? :admin

    flash[:error] = 'You are not authorized to view that page.'
    redirect_to root_path
  end
end

