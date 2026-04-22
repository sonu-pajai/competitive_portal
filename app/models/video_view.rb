class VideoView < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  validates :user_id, uniqueness: { scope: :lesson_id }

  def increment_view!
    increment!(:view_count)
    update!(last_viewed_at: Time.current)
  end

  def limit_reached?
    view_count >= lesson.max_views
  end
end
