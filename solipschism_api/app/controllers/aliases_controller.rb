class AliasesController < ApiController
  before_action :require_login

  def index
    render json: { aliases: 'List of Aliases that have been associated with this user'}
  end
end
