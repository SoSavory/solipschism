class UsersController < ApiController
  before_action :require_login, except: [:create]

  def create
    name            = params[:name]
    email           = params[:email]
    password        = params[:password]
    opts_to_compute = params[:opts_to_compute]

    user = User.new(name: name, email: email, password: password, opts_to_compute: opts_to_compute)
    if user.save!
      user.allow_token_to_be_used_only_once
      message = {token: user.token}
      status = :ok
    else
      message = { errors: [ { detail: "There was a problem with your registration" } ] }
      status = :bad_request
    end
    render json: message, status: status
  end

end
