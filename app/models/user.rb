class User < ApplicationRecord
  enum role: { basic: 0, admin: 1 }

  has_many :created, class_name: 'User',
                     foreign_key: 'creator_id'

  belongs_to :creator, class_name: 'User', optional: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :ldap_authenticatable, :registerable, :database_authenticatable, :rememberable, :trackable

  before_create :ldap_before_create

  def short_name
    name_array = name.split(' ')
    lname = name_array[0]
    fname = "#{name_array[1][0].upcase}." unless name_array[1].nil?
    pname = "#{name_array[2][0].upcase}." unless name_array[2].nil?
    fname.nil? && pname.nil? ? lname : "#{lname} #{fname}#{pname}"
  end

  def has_role?(role)
        self.role.to_sym == role
  end

  private

  def ldap_before_create
    if Devise::LDAP::Adapter.valid_login?(self.username)
      self.name = Devise::LDAP::Adapter.get_ldap_param(self.username, 'name').try(:first) || username
      self.email = Devise::LDAP::Adapter.get_ldap_param(self.username, 'mail').try(:first) ||
                   "#{username}@#{Rails.application.credentials.devise.domain_name}"
      groups = Devise::LDAP::Adapter.get_ldap_param(self.username, 'memberof').map do |group|
        group.match(/CN=[а-яА-Яa-zA-Z]+\s*[а-яА-Яa-zA-Z]*/).to_s.split('=')[1]
      end

      self.role = 1 if groups.include?('Domain Admins')
    end
  end
end
