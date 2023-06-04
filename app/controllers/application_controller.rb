class ApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate_user!

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end

  def after_sign_in_path_for(resource)
    home_path
  end
end
