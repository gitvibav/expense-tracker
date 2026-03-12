class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'
  
  validates :user_id, uniqueness: { scope: :friend_id }
  validates :status, inclusion: { in: %w[pending accepted] }
  
  def self.between(user1, user2)
    where(user: user1, friend: user2).or(where(user: user2, friend: user1))
  end
end
