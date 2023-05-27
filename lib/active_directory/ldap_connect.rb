# frozen_string_literal: true

require 'net-ldap'

module ActiveDirectory
  class LdapConnect
    def initialize
      @host = Rails.application.credentials.dig(:ldap, :host)
      @port = Rails.application.credentials.dig(:ldap, :port)
      @dc1 = Rails.application.credentials.dig(:ldap, :base, :dc1)
      @dc2 = Rails.application.credentials.dig(:ldap, :base, :dc2)
      @ou1 = Rails.application.credentials.dig(:ldap, :base, :ou1)
      @ou2 = Rails.application.credentials.dig(:ldap, :base, :ou2)
      @admin_login = Rails.application.credentials.dig(:ldap, :admin_user)
      @admin_password = Rails.application.credentials.dig(:ldap, :admin_password)
    end

    def read
      ldap = Net::LDAP.new(host: @host, port: @port)
      treebase = "OU=#{@ou2}, OU=#{@ou1}, DC=#{@dc2}, DC=#{@dc1}"

      ldap.auth @admin_login, @admin_password

      ldap.search(base: treebase).map do |entry|
        {
          name: entry['name'][0].to_s,
          email: entry['mail'][0].to_s,
          username: entry['samaccountname'][0].to_s
        }
      end
    end

    # puts @ldap.bind ? true : false

    # @filter = ~ Net::LDAP::Filter.eq('CN', 'ExchangeActiveSyncDevices') & Net::LDAP::Filter.eq('CN', '*')
    # @filter = ~ Net::LDAP::Filter.eq('CN', 'ExchangeActiveSyncDevices')
    # @filter = ~ Net::LDAP::Filter.eq('objectClass', 'ExchangeActiveSyncDevices')
    # @filter = Net::LDAP::Filter.eq('CN', '*')

    #:objectclass
    # CN=ExchangeActiveSyncDevices,CN=Мартынов Павел Сергеевич,OU=USERS,OU=REDSTAR,DC=redstar,DC=ru

    # @ldap.search(base: @treebase)[20].each { |key, value| p "#{key}: #{value}" }

    # puts @ldap.search(base: @treebase)[20]['name']

    # @groups = @ldap.search(bse: @treebase).map do |group|
    # name = group['name'].first.to_s
    # Group.new(name: name)
    # end

    # @ldap.search(base: @treebase) do |entry|
    # p "DN: #{entry.dn}"
    # end

    # p @ldap.search(base: @treebase)[1]
  end
end
