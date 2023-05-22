class User < ApplicationRecord

  # перечисление для ролей пользователя (базовый - 0, администратор - 1)
  enum role: { basic: 0, admin: 1 }

  # внутрення связь в модели для создания связи Создатель / Созданный
  # (необходимо для отслеживания, кем был создан пользователь)
  has_many :created, class_name: 'User',
                     foreign_key: 'creator_id'

  belongs_to :creator, class_name: 'User', optional: true

  # свойства devise
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :ldap_authenticatable, :registerable, :database_authenticatable, :rememberable, :trackable

  # коллбэк дл вызова метода ldap_before_create
  before_create :ldap_before_create

  # получение короткого имени формата Петров И.И.
  def short_name
    name_array = name.split(' ')
    lname = name_array[0]
    fname = "#{name_array[1][0].upcase}." unless name_array[1].nil?
    pname = "#{name_array[2][0].upcase}." unless name_array[2].nil?
    fname.nil? && pname.nil? ? lname : "#{lname} #{fname}#{pname}"
  end

  # проверка роли администратора сайта
  def has_role?(role)
    self.role.to_sym == role
  end

  private

  # получить определённые данные с контроллера домена перед созданием пользовотеля
  # в случае, если проверка подключения нет, то может свалится, проверить полученные данные из контроллера
  def ldap_before_create

    # перрвать выполнение метода, если нет подключения к контроллеру домена
    return unless Devise::LDAP::Adapter.valid_login?(username)

    # попытка получения имени пользователя, если нет, то использовать логин
    self.name = Devise::LDAP::Adapter.get_ldap_param(username, 'name').try(:first) || username

    # попытка получения электронной почты пользователя, если нет, то создать интерполяцинй из логина и иммени домена
    self.email = Devise::LDAP::Adapter.get_ldap_param(username, 'mail').try(:first) ||
                 "#{username}@#{Rails.application.credentials.devise.domain_name}"

    # получение списка групп, в которых состоит пользватель
    groups = Devise::LDAP::Adapter.get_ldap_param(username, 'memberof')

    # перрвать выполнение метода, если пользователь не состоит в группах
    return unless  groups

    # получить группы из массива в установленном формате (убрать узлы из состава названия группы)
    groups.map! do |group|
      group.match(/CN=[а-яА-Яa-zA-Z]+\s*[а-яА-Яa-zA-Z]*/).to_s.split('=')[1]
    end

    # установить роль администратора, если пользователь состоит в группе доменных администраторов
    # вынести список групп для проверки членства в credentials
    self.role = 1 if groups.any? { |group| Rails.application.credentials.dig(:ldap, :admin_groups).include?(group) }
  end
end
