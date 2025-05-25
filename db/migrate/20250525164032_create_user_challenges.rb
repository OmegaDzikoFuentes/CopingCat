class CreateUserChallenges < ActiveRecord::Migration[8.0]
  def change
    create_table :user_challenges do |t|
      t.timestamps
    end
  end
end
