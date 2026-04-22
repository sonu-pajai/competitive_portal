class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, default: 0, null: false
      t.string :thumbnail_url
      t.integer :status, default: 0, null: false
      t.string :exam_category
      t.integer :duration_days, default: 365

      t.timestamps
    end

    add_index :courses, :exam_category
    add_index :courses, :status
  end
end
