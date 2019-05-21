# frozen_string_literal: true

class Api::ArticlesController < ApiController
  # Out of the box, rails comes with CSRF which is problematic when developing APIs, thus CSRF can be turned off on a controller basis.
  # before_action :authorize, only: [:create, :edit, :update, :destroy]
  before_action :set_article, only: [:show, :update, :destroy]
  skip_before_action :authorize_request, only: [:hello, :empty]

  #
  # EXP
  #
  skip_before_action :authorize_request, only: :index

  # skip_before_action :verify_authenticity_token, only: :hello


  include Response # `./app/controllers/concerns/`
  include ExceptionHandler # `./app/controllers/concerns/`

  # NOTE: no GET response cuz no route points to this method.
  def foo # on purpose
    puts 'hello from ./app/controllers/api/articles_controller#foo'
  end

  # GET /api/hello
  # GET /api/hell0 # defined in `routes.rb`
  def hello
    render json: 'hello from ./app/controllers/api/articles_controller#hello'
  end

  def empty
    render json: []
  end

  # GET /api/articles
  def index
    # get the current user articles
    # @articles = current_user.Articles

    @articles = Article.all
    json_response(ArticleSerializer.new(@articles).serialized_json)

    # @articles = Article.all
    # json_response(@articles) # WORKS

  end

  # NOTE: `create` generates an object, and saves it to the DB whereas  `new` just generates an object, that will later require saving to the DB.
  # NOTE: `create!` will raise an exception

  # POST /api/articles
  def create
    # create articles belonging to current user
    # @article = current_user.article.create!(article_params)
    
    @article = Article.create!(article_params)
    json_response(@article, :created)
  end

  # GET /articles/:id
  def show
    json_response(@article)
  end

  # PUT /articles/:id
  def update
    @article.update(article_params)
    head :no_content
  end

  # DELETE /articles/:id
  def destroy
    @article.destroy
    head :no_content
  end

  private
  def set_article
    @article = Article.find(params[:id])
  end

  # NOTE: doublecheck `./app/modles/article.rb` as well.
  def article_params
    params.permit(:title, :text, :slug)
  end

  def authorize
    redirect_to login_url, alert: "Not authorized" if current_user.nil?
  end

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      reset_session
    end
  end
end
