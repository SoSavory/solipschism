class ArticlesController < ApiController

  before_action :require_login

  def index
    # we want articles whose alias belongs to the current user
    articles = Article.joins(:alias).where(aliases: {user_id: current_user}).pluck(:id, :title, :body).map{ |a| {id: a[0], title: a[1], body: a[2] } }
    render json: {articles: articles}
  end

  def create
    user_alias = current_user.current_alias
    title = params[:title]
    body = params[:body]

    article = Article.new(alias_id: user_alias, title: title, body: body)

    if article.save
      message = { message: "Successfully Created an Article" }
      status = :ok
    else
      message = { errors: [ { detail: "This Article could not be created" } ] }
      status = :bad_request
    end

    render json: message, status: status
  end

  def show
    article = Article.where(id: params[:id]).pluck(:id, :title, :body)[0]
    render json: {article: article}, status: :ok
  end

  def show_matched_day
    if params[:date].to_date <= Date.today
      user_alias = current_user.alias_on_date(params[:date].to_date)
      # We want to grab all the articles belonging to all aliases that have a match with the users alias
      # matched_aliases = MatchedAlias.where(alias_id: user_alias).pluck(:matched_alias_id)
      # matched_articles = Article.where(alias_id: matched_aliases).pluck(:id, :title, :body)
      matched_articles = Alias.includes(:articles, :matched_aliases)
                              .references(:articles, :matched_aliases).where('matched_aliases.matched_alias_id = ?', user_alias)
                              .where('articles.id IS NOT NULL')
                              .pluck('articles.id, articles.title, articles.body')

      articles = []
      matched_articles.each do |ma|
        articles.push( { id: ma[0], title: ma[1], body: ma[2] } )
      end
      response = {articles: articles}
      staus = :ok
    else
      response = { errors: [ { detail: "You cannot request matched articles from the future" } ] }
      status = :bad_request
    end
    render json: response, status: status
  end


end
