class Course < ApplicationRecord
  enum :status, { draft: 0, published: 1, archived: 2 }

  has_many :lessons, -> { order(:position) }, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_one_attached :thumbnail

  validates :title, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { published }

  def total_duration
    lessons.sum(:duration_seconds)
  end

  def lesson_count
    lessons.count
  end
end
