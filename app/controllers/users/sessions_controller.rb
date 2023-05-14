# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    possible_user = User.where(username: params['user']['username'])

    # if params[:log] == 'local'
    if possible_user.any?
      self.resource = warden.authenticate!(:database_authenticatable)

      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      super

      # self.resource = warden.authenticate!(:ldap_authenticatable)

      # sign_in(resource_name, resource)
      # yield resource if block_given?
      # respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end
end
