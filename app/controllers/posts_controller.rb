class PostsController < ApplicationController
  def show
    @post = Post.published.includes(plan: :creator).find(params[:id])
  end
end
