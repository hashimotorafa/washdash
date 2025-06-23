module CompanyArea
  class UsersController < CompanyArea::ApplicationController
    before_action :set_user, only: [:edit, :update]

    def index
      @users = current_company.users.ordered
    end

    def new
      @user = current_company.users.build
    end

    def create
      @user = current_company.users.build(user_params)

      if @user.save
        redirect_to company_area_users_path, notice: "Usuário criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      # Não atualiza a senha se estiver em branco
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if @user.update(user_params)
        redirect_to company_area_users_path, notice: "Usuário atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = current_company.users.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :status
      )
    end
  end
end 