module ApplicationHelper
  def user_params(user)
    { 'user[name]': user.name, 'user[username]': user.username, 'user[email]': user.email }
  end

  def user_roles
    User.roles.map { |key, _| key }
  end
end
