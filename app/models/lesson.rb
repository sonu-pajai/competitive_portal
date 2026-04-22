class Lesson < ApplicationRecord
  belongs_to :course
  has_many :video_views, dependent: :destroy
  has_one_attached :video

  validates :title, presence: true
  validates :max_views, numericality: { greater_than: 0 }

  def views_remaining_for(user)
    vv = video_views.find_by(user: user)
    return max_views unless vv
    [max_views - vv.view_count, 0].max
  end

  def viewable_by?(user)
    views_remaining_for(user) > 0
  end
end
