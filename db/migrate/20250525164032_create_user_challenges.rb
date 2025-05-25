class CreateUserChallenges < ActiveRecord::Migration[7.1]
  def change
    create_table :user_challenges do |t|
      t.timestamps
    end
  end
end
