module Admin
  class UsersController < Admin::ApplicationController
    before_action :set_user, only: [ :show, :edit, :update, :destroy ]

    def index
      @users = User.ordered
    end

    def show
    end

    def new
      @user = User.new
    end

    def edit
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_user_path(@user), notice: "Usu\u00E1rio criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      # Não atualiza a senha se estiver em branco
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "Usu\u00E1rio atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "Usu\u00E1rio removido com sucesso.", status: :see_other
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :status,
        :admin
      )
    end
  end
end
