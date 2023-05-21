class AddCreatorRefToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :creator, foreign_key: { to_table: :users }
  end
end
