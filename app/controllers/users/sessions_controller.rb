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

    # логика следующая: аутентификация всегда из локальной базы данных.
    # В случае отсутствия пользователя в локальной базе данных проверяется его наличие в доменном контроллере.
    # Если в доменном контроллере присутствует, создается новый, обновляются его свойства и сохраняются в локальной базе данных.
    # Если в локальной базе данных присутствует, но не совпадает пароль, проверяется валидность пароля в доменном контроллере,
    # и, если валидный, обновлетс в локальной базе данных.

    # если пользователя нет в локальной базе данных и в доменном контроллере, уведомляем его о нвозможности аутентификации
    if !possible_user && Devise::LDAP::Adapter.valid_credentials?(username, password)
      redirect_to sign_in_path
      set_flash_message(:alert, :signed_in_db)
    end


    # если пользователя нет в локальной базе данных, но есть в доменном контроллере
    if !possible_user && Devise::LDAP::Adapter.valid_credentials?(username, password)

      # создаем нового пользователя
      possible_user = User.new

      # присваиваем соответствующии атриьуты, полученые из формы
      possible_user.username = username
      possible_user.password = password

      # если имя отсутствует, получаем из контроллера домена или используем логин в качестве имени
      unless possible_user.name.present?
        possible_user.name = Devise::LDAP::Adapter.get_ldap_param(username, 'name').try(:first) ||
                             username
      end

      # если электронная почта отсутствует, получаем из контроллера домена или создаем из логина
      # и имени домена
      unless possible_user.email.present?
        possible_user.email = Devise::LDAP::Adapter.get_ldap_param(username, 'mail').try(:first) ||
                              "#{username}@#{Rails.application.credentials.devise.domain_name}"
      end

      # получаем список групп, в которых состоит пользователь
      groups = Devise::LDAP::Adapter.get_ldap_param(username, 'memberof')

      # прерывем выполнение метода, если пользователь не состоит в группах
      return unless groups

      # получаем группы из массива в установленном формате (убрать узлы из состава названия группы)
      groups.map! do |group|
        group.match(/CN=[а-яА-Яa-zA-Z]+\s*[а-яА-Яa-zA-Z]*/).to_s.split('=')[1]
      end

      # установливаем роль администратора, если пользователь состоит в группе доменных администраторов
      # выносим список групп для проверки членства в credentials
      if groups.any? { |group| Rails.application.credentials.dig(:ldap, :admin_groups).include?(group) }
        possible_user.role = 1
      end

      # сохраняем обновалённые данные пользователя
      possible_user.save!
    end

    # обновляем пользовтеля если его нет в локальной базе данных, но существует в контроллеретдомена
    possible_user.update!(user_params) if possible_user&.!valid_password?(params[:user][:password]) &&
                                                          Devise::LDAP::Adapter.valid_credentials?(username, password)

    # проверяем наличие пользователя в локальной базе данных и валидность пароля из локальной базы данных
    if possible_user&.valid_password?(params[:user][:password])

      # аутентификация в локальной базе данных
      self.resource = warden.authenticate!(:database_authenticatable)
      set_flash_message(:notice, :signed_in_db)

      # следующие три строчки кода - копипаста с stackoverflow
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
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

  def user_params
    params.require(:user).permit(:password)
  end
end
