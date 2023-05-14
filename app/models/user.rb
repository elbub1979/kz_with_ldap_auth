class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :ldap_authenticatable, :registerable, :database_authenticatable, :rememberable, :trackable

  before_save :ldap_before_save

  private

  def ldap_before_save
    self.name = Devise::LDAP::Adapter.get_ldap_param(self.username, "name").try(:first) || username
    self.email = Devise::LDAP::Adapter.get_ldap_param(self.username, "mail").try(:first) ||
      "#{username}@#{Rails.application.credentials.devise.domain_name}"
  end
end
