class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :ensure_course_published!
  before_action :ensure_enrolled!

  skip_forgery_protection only: :record_view

  def index
    @lessons = @course.lessons.order(:position)
  end

  def show
    @lesson = @course.lessons.find(params[:id])
    @views_remaining = @lesson.views_remaining_for(current_user)
  end

  def watch
    @lesson = @course.lessons.find(params[:id])

    unless @lesson.viewable_by?(current_user)
      redirect_to course_lesson_path(@course, @lesson), alert: "View limit reached for this lesson."
      return
    end

    @video_url = VideoStreamService.new(@lesson, current_user).stream_url
    @views_remaining = @lesson.views_remaining_for(current_user)
  end

  # POST - called via AJAX when video starts playing
  def record_view
    @lesson = @course.lessons.find(params[:id])
    service = VideoStreamService.new(@lesson, current_user)
    service.record_view!
    render json: { views_remaining: @lesson.views_remaining_for(current_user) }
  rescue VideoStreamService::ViewLimitReached
    render json: { error: "View limit reached" }, status: :forbidden
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def ensure_course_published!
    redirect_to courses_path, alert: "This course is not available." unless @course.published?
  end

  def ensure_enrolled!
    redirect_to @course, alert: "Your enrollment has expired or you are not enrolled." unless current_user.enrolled_in?(@course)
  end
end
