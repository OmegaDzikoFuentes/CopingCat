class AddSessionDurationToAppUsages < ActiveRecord::Migration[7.1]
  def change
    add_column :app_usages, :session_duration, :integer
  end
end
