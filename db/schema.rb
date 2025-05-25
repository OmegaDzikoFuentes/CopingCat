# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_25_164126) do
  create_table "app_usages", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "action"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_app_usages_on_user_id"
  end

  create_table "behavior_reactions", force: :cascade do |t|
    t.integer "emotional_episode_id", null: false
    t.string "action_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emotional_episode_id"], name: "index_behavior_reactions_on_emotional_episode_id"
  end

  create_table "cat_customizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cats", force: :cascade do |t|
    t.string "name"
    t.string "model_filename"
    t.string "category"
    t.boolean "customizable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "challenges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contexts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "location"
    t.string "activity"
    t.string "social_context"
    t.string "physiological"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contexts_on_user_id"
  end

  create_table "coping_strategies", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "diary_entries", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "emotion_id", null: false
    t.integer "context_id", null: false
    t.text "notes"
    t.integer "intensity"
    t.string "location"
    t.string "activity"
    t.datetime "entry_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context_id"], name: "index_diary_entries_on_context_id"
    t.index ["emotion_id"], name: "index_diary_entries_on_emotion_id"
    t.index ["user_id"], name: "index_diary_entries_on_user_id"
  end

  create_table "emotional_episode_emotions", force: :cascade do |t|
    t.integer "emotional_episode_id", null: false
    t.integer "emotion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emotion_id"], name: "index_emotional_episode_emotions_on_emotion_id"
    t.index ["emotional_episode_id"], name: "index_emotional_episode_emotions_on_emotional_episode_id"
  end

  create_table "emotional_episodes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "trigger_id", null: false
    t.integer "emotion_id", null: false
    t.integer "diary_entry_id", null: false
    t.integer "context_id", null: false
    t.integer "intensity"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context_id"], name: "index_emotional_episodes_on_context_id"
    t.index ["diary_entry_id"], name: "index_emotional_episodes_on_diary_entry_id"
    t.index ["emotion_id"], name: "index_emotional_episodes_on_emotion_id"
    t.index ["trigger_id"], name: "index_emotional_episodes_on_trigger_id"
    t.index ["user_id"], name: "index_emotional_episodes_on_user_id"
  end

  create_table "emotions", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "episode_coping_strategies", force: :cascade do |t|
    t.integer "emotional_episode_id", null: false
    t.integer "coping_strategy_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "effectiveness"
    t.index ["coping_strategy_id"], name: "index_episode_coping_strategies_on_coping_strategy_id"
    t.index ["emotional_episode_id"], name: "index_episode_coping_strategies_on_emotional_episode_id"
  end

  create_table "episode_tags", force: :cascade do |t|
    t.integer "emotional_episode_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emotional_episode_id"], name: "index_episode_tags_on_emotional_episode_id"
    t.index ["tag_id"], name: "index_episode_tags_on_tag_id"
  end

  create_table "episode_trigger_intensities", force: :cascade do |t|
    t.integer "emotional_episode_id", null: false
    t.integer "trigger_id", null: false
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emotional_episode_id"], name: "index_episode_trigger_intensities_on_emotional_episode_id"
    t.index ["trigger_id"], name: "index_episode_trigger_intensities_on_trigger_id"
  end

  create_table "physical_symptoms", force: :cascade do |t|
    t.integer "emotional_episode_id", null: false
    t.string "name"
    t.integer "severity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emotional_episode_id"], name: "index_physical_symptoms_on_emotional_episode_id"
  end

  create_table "prediction_feedbacks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "predicted_trigger_id", null: false
    t.string "actual_outcome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["predicted_trigger_id"], name: "index_prediction_feedbacks_on_predicted_trigger_id"
    t.index ["user_id"], name: "index_prediction_feedbacks_on_user_id"
  end

  create_table "strategy_usage_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trigger_patterns", force: :cascade do |t|
    t.integer "trigger_id", null: false
    t.integer "user_id", null: false
    t.string "frequency"
    t.string "time_of_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trigger_id"], name: "index_trigger_patterns_on_trigger_id"
    t.index ["user_id"], name: "index_trigger_patterns_on_user_id"
  end

  create_table "triggers", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.string "trigger_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_cat_customizations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "color"
    t.string "accessory"
    t.string "texture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_cat_customizations_on_user_id"
  end

  create_table "user_challenges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_goals", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "target_trigger_id", null: false
    t.integer "target_emotion_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_emotion_id"], name: "index_user_goals_on_target_emotion_id"
    t.index ["target_trigger_id"], name: "index_user_goals_on_target_trigger_id"
    t.index ["user_id"], name: "index_user_goals_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.integer "age"
    t.string "gender"
    t.string "occupation"
    t.text "lifestyle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone"
    t.string "cat_model"
  end

  add_foreign_key "app_usages", "users"
  add_foreign_key "behavior_reactions", "emotional_episodes"
  add_foreign_key "contexts", "users"
  add_foreign_key "diary_entries", "contexts"
  add_foreign_key "diary_entries", "emotions"
  add_foreign_key "diary_entries", "users"
  add_foreign_key "emotional_episode_emotions", "emotional_episodes"
  add_foreign_key "emotional_episode_emotions", "emotions"
  add_foreign_key "emotional_episodes", "contexts"
  add_foreign_key "emotional_episodes", "diary_entries"
  add_foreign_key "emotional_episodes", "emotions"
  add_foreign_key "emotional_episodes", "triggers"
  add_foreign_key "emotional_episodes", "users"
  add_foreign_key "episode_coping_strategies", "coping_strategies"
  add_foreign_key "episode_coping_strategies", "emotional_episodes"
  add_foreign_key "episode_tags", "emotional_episodes"
  add_foreign_key "episode_tags", "tags"
  add_foreign_key "episode_trigger_intensities", "emotional_episodes"
  add_foreign_key "episode_trigger_intensities", "triggers"
  add_foreign_key "physical_symptoms", "emotional_episodes"
  add_foreign_key "prediction_feedbacks", "predicted_triggers"
  add_foreign_key "prediction_feedbacks", "users"
  add_foreign_key "trigger_patterns", "triggers"
  add_foreign_key "trigger_patterns", "users"
  add_foreign_key "user_cat_customizations", "users"
  add_foreign_key "user_goals", "target_emotions"
  add_foreign_key "user_goals", "target_triggers"
  add_foreign_key "user_goals", "users"
end
