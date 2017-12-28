class ArticlesController < ApiController

  before_action :require_login

  def index
    # we want articles whose alias belongs to the current user
    articles = Article.where(user_id: current_user.id).order("articles.created_at DESC")
    .pluck(:id, :title, :body, :created_at).map{ |a| {id: a[0], title: a[1], body: a[2], created_at: a[3] } }
    render json: {articles: articles}
  end

  def create

    title = params[:title]
    body = params[:body]

    article = Article.new(user_id: current_user, title: title, body: body)

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
    article = Article.where(id: params[:id]).pluck(:id, :title, :body, :created_at).map{ |a| {id: a[0], title: a[1], body: a[2], created_at: a[3] } }
    render json: {article: article}, status: :ok
  end

  def show_matched_day
    date = params[:date].to_date.to_time
    if date <= Date.today
      # We want to grab all the articles belonging to all aliases that have a match with the users alias
      # matched_aliases = MatchedAlias.where(alias_id: user_alias).pluck(:matched_alias_id)
      # matched_articles = Article.where(alias_id: matched_aliases).pluck(:id, :title, :body)
      matched_articles = User.includes(:articles, :matched_users)
                              .references(:articles, :matched_users).where('matched_users.matched_user_id = ?', current_user)
                              .where('matched_users.created_at > ? AND matched_users.created_at < ?', date.beginning_of_day, date.end_of_day)
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

  def show_today
    date = Date.today

    matched_articles = User.includes(:articles, :matched_users)
                            .references(:articles, :matched_users)
                            .where('matched_users.matched_user_id = ?', current_user)
                            .where('matched_users.created_at > ? AND matched_users.created_at < ?', date.beginning_of_day, date.end_of_day)
                            .where('articles.id IS NOT NULL')
                            .pluck('articles.id, articles.title, articles.body')
                            .map{ |a| {id: a[0], title: a[1], body: a[2], created_at: a[3] } }
    response = {articles: matched_articles}
    status = :ok
    render json: response, status: status

  end


end
