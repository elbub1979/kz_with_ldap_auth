class UsersController < ApplicationController
  before_action :set_user, except: %i[index new create]

  def index
    @users = User.all
  end

  def show
    authorize User
  end

  def new
    @user = User.new
    authorize User
  end

  def create
    @user = User.new(user_params)

    authorize User

    @creator = current_user
    @user.update_attribute(:creator_id, @creator.id)

    if params[:user][:password].empty?
      password_length = 8
      password = Devise.friendly_token.first(password_length)
      @user.update_attribute(:password, password)
      @user.update_attribute(:password_confirmation, password)
    end

    if @user.save
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize User
  end

  def update
    authorize User

    if @user.update(user_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize User
  end


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
    params.require(:user).permit(:username, :name, :email, :password, :password_confirmation, :role)
  end

end
