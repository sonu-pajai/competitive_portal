class CreateVideoViews < ActiveRecord::Migration[8.0]
  def change
    create_table :video_views do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.integer :view_count, default: 0, null: false
      t.datetime :last_viewed_at

      t.timestamps
    end

    add_index :video_views, [:user_id, :lesson_id], unique: true
  end
end
