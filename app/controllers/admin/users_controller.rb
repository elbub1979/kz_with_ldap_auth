class Admin::UsersController < AdminController
  before_action :set_user, only: %i[edit update destroy]

  # standart actions

  def new
    @user = User.new
  end

  def create
    @creator = current_user
    @user = User.new(user_params)
    @user.update_attribute(:creator_id, @creator.id)

    if @user.save
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy; end

  # custom actions

  def ldap_users
    ad = ActiveDirectory::LdapConnect.new
    @users = ad.read.map { |user| User.new(user) }.sort_by { |user| user[:name] }
    render 'users/index'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :username, :email)
  end
end
