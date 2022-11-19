class PostsController < ApplicationController
    before_action :authenticate_account!, except: [ :index, :show ]
    before_action :set_post, only: [:show]
    before_action :auth_subscriber, only: [:new]
    helper_method :params

    def index
        subscriptions = Subscription.where(account_id: current_account)
        front_page_posts = Array.new
        subscriptions.each { |subscription|
            if Community.find(subscription.community_id).posts === []

            else
                front_page_posts.push(Community.find(subscription.community_id).posts)
            end
        }

        if params[:sort] === "new"
            # time parameter will eventually be used to sort by time rather than order
            @posts = Post.order("#{params[:time]} DESC").limit(20)
        elsif params[:sort] === "front_page"
            @posts = front_page_posts.flatten
        end

        @url = request.original_url
        @communities = Community.all.order(id: :desc).limit(5)
    end

    def show 
        @comment = Comment.new
    end

    def new
        @community = Community.find(params[:community_id])
        @post = Post.new
    end

    def create
        @post = Post.new post_params
        @post.account_id = current_account.id
        @post.community_id = params[:community_id]
        @community = Community.find(params[:community_id])
        if @post.save
            @vote = Vote.new
            @vote.account_id = current_account.id
            @vote.post_id = @post.id
            @vote.upvote = true
            @vote.save
            @vote.account.increment!(:karma, 1)
            redirect_to community_path(@community)
        else
            @community = Community.find(params[:community_id])
            render :new 
        end
    end

    def destroy
        @post = Post.find(params[:id])
        @post.destroy

        if @post.destroyed?
            respond_to do |format|
                format.js {
                    render "posts/delete"
                }
            end
        end

    end

    private

    def set_post
        @post = Post.includes(:comments).find(params[:id])
    end

    def auth_subscriber
        @community = Community.find(params[:community_id])
        unless Subscription.where(community_id: params[:community_id], account_id: current_account.id).any?
            redirect_to community_path(@community), flash: {danger: "You aren't subscribed to this community"}
        end
    end

    def post_params
        params.require(:post).permit(:title, :body)
    end

end