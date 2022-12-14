class CommentsController < ApplicationController

    def create
        @comment = Comment.new comment_params
        @comment.account_id = current_account.id
        @comment.post.increment!(:total_comments, 1) 
        @post = @comment.post

        respond_to do |format|
            format.js {
            if @comment.save
                @comments = Comment.where(post_id: @comment.post_id)
                render "comments/create"
            else
                # unable to save
            end
            }
        end
    end

    def destroy

        @comment = Comment.find(params[:id])
        @post = @comment.post
        @comment.delete

        if @comment.destroyed?
            @post.decrement!(:total_comments, 1)
            respond_to do |format|
                format.js {
                    render "comments/delete"
                }
            end
        end
    end

    private 

    def comment_params
        params.require(:comment).permit(:message, :post_id)
    end

end