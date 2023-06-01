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
  # before_create :ldap_before_create

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
end
