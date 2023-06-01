# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    # приведение в нижний регистр данных, полученных из формы
    username = params['user']['username'].downcase
    password = params['user']['password']
    # поиск пользователя в лоакльной базе данных
    possible_user = User.find_by(username: username)

    # выбор стратегии аутентификации

    # логика следующая: при наличии пользователя в локальной базе данных происходит аутентийикация пользователя
    # из локальной базы данных, если нет в локальной базе данных, аутентийикаия пользователя происходит из
    # контроллера домена

    # проверка наличия пользователя в локальной базе данных и валидности пароля из локальной базы данных
    if possible_user&.valid_password?(params[:user][:password])

      # аутентификация в локальной базе данных
      self.resource = warden.authenticate!(:database_authenticatable)
    else

      # проверка наличия пользвателя в локальной базе данных и валидности данных,
      # полученных из формы ввода на сайте, в контроллере домена

      possible_user.update(user_params) if possible_user && Devise::LDAP::Adapter.valid_credentials?(username, password)

      # аутентификация ldap
      self.resource = warden.authenticate!(:ldap_authenticatable)

      # если пользователь отсутствует в локальной базе данных (новый)
      unless possible_user

        # получить созданного пользователя после ldap аутентификации в локальной базе данных
        new_user = User.find_by(username: username)

        # если имя отсутствует, получить из контроллера домена или использовать логин в качестве имени
        unless new_user.name.present?
          new_user.name = Devise::LDAP::Adapter.get_ldap_param(username, 'name').try(:first) || username
        end

        # если электронная почта отсутствует, получить из контроллера домена или использовать создать из логина
        # и имени домена
        unless new_user.email.present?
          new_user.email = Devise::LDAP::Adapter.get_ldap_param(username, 'mail').try(:first) ||
                           "#{username}@#{Rails.application.credentials.devise.domain_name}"
        end

        # получить список групп, в которых состоит пользователь
        groups = Devise::LDAP::Adapter.get_ldap_param(username, 'memberof')

        # прервать выполнение метода, если пользователь не состоит в группах
        return unless groups

        # получить группы из массива в установленном формате (убрать узлы из состава названия группы)
        groups.map! do |group|
          group.match(/CN=[а-яА-Яa-zA-Z]+\s*[а-яА-Яa-zA-Z]*/).to_s.split('=')[1]
        end

        # установить роль администратора, если пользователь состоит в группе доменных администраторов
        # вынести список групп для проверки членства в credentials
        if groups.any? { |group| Rails.application.credentials.dig(:ldap, :admin_groups).include?(group) }
          new_user.role = 1
        end

        # сохранить обновалённые данные пользователя
        new_user.save!
      end
    end

    # следующие три строчки кода - копипаста с stackoverflow
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
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

  def user_params
    params.require(:user).permit(:password)
  end
end
