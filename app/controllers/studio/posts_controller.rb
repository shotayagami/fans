module Studio
  class PostsController < BaseController
    before_action :set_post, only: %i[edit update destroy]

    def index
      @posts = Post.where(plan: current_user.plans).includes(:plan).order(created_at: :desc)
    end

    def new
      @post = Post.new(published_at: Time.current)
    end

    def create
      @post = Post.new(post_params)
      if @post.save
        redirect_to studio_posts_path, notice: "投稿しました"
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @post.update(post_params)
        redirect_to studio_posts_path, notice: "投稿を更新しました"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @post.destroy!
      redirect_to studio_posts_path, notice: "投稿を削除しました", status: :see_other
    end

    private

    def set_post
      @post = Post.where(plan: current_user.plans).find(params[:id])
    end

    # plan_id is checked against the creator's own plans so a post cannot be attached to someone else's plan.
    def post_params
      params.expect(post: %i[plan_id title body image published_at]).tap do |attrs|
        attrs[:plan_id] = current_user.plans.find(attrs[:plan_id]).id if attrs.key?(:plan_id)
      end
    end
  end
end
