class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.string :title, null: false
      t.text :description
      t.references :course, null: false, foreign_key: true
      t.integer :position, default: 0
      t.string :video_key
      t.integer :duration_seconds, default: 0
      t.integer :max_views, default: 5, null: false

      t.timestamps
    end

    add_index :lessons, [:course_id, :position]
  end
end
