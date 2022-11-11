class Post < ActiveRecord::Base
    # extend FriendlyId
    # friendly_id :community_id, use: :slugged
    belongs_to :account
    belongs_to :community
    has_many :comments
    validates_presence_of :title, :body, :account_id, :community_id
end