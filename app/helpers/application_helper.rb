module ApplicationHelper
  def user_params(user)
    { 'user[name]': user.name, 'user[username]': user.username, 'user[email]': user.email }
  end

  def user_roles
    User.roles.map { |key, _| key }
  end

  def flash_class(level)
    bootstrap_alert_class = {
      "success" => "alert-success",
      "error" => "alert-danger",
      "notice" => "alert-info",
      "alert" => "alert-danger",
      "warn" => "alert-warning"
    }
    bootstrap_alert_class[level]
  end
end
