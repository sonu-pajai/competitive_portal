class VideoStreamService
  def initialize(lesson, user)
    @lesson = lesson
    @user = user
  end

  def stream_url
    if Rails.env.production?
      s3_presigned_url
    else
      local_url
    end
  end

  def record_view!
    vv = VideoView.find_or_initialize_by(user: @user, lesson: @lesson)
    raise ViewLimitReached, "You have reached the maximum views for this lesson" if vv.persisted? && vv.limit_reached?

    vv.increment!(:view_count)
    vv.update!(last_viewed_at: Time.current)
    vv
  end

  private

  def s3_presigned_url
    signer = Aws::S3::Presigner.new(client: s3_client)
    signer.presigned_url(:get_object,
      bucket: ENV["S3_BUCKET"],
      key: @lesson.video_key,
      expires_in: 3600
    )
  end

  def local_url
    return nil unless @lesson.video.attached?
    Rails.application.routes.url_helpers.rails_blob_path(@lesson.video, disposition: "inline", only_path: true)
  end

  def s3_client
    Aws::S3::Client.new(
      region: ENV.fetch("AWS_REGION", "ap-south-1"),
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )
  end

  class ViewLimitReached < StandardError; end
end
