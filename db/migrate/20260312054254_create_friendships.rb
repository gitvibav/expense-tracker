class CreateFriendships < ActiveRecord::Migration[8.1]
  def change
    create_table :friendships do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :friend, null: false, foreign_key: { to_table: :users }
      t.string :status, default: 'accepted', null: false

      t.timestamps
    end
    
    add_index :friendships, [:user_id, :friend_id], unique: true
  end
end
