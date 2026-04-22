class Admin::LessonsController < Admin::BaseController
  before_action :set_course
  before_action :set_lesson, only: [:edit, :update, :destroy]

  def index
    @lessons = @course.lessons.order(:position)
  end

  def new
    @lesson = @course.lessons.build
  end

  def create
    @lesson = @course.lessons.build(lesson_params)
    if @lesson.save
      redirect_to admin_course_lessons_path(@course), notice: "Lesson created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @lesson.update(lesson_params)
      redirect_to admin_course_lessons_path(@course), notice: "Lesson updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lesson.destroy!
    redirect_to admin_course_lessons_path(@course), notice: "Lesson deleted."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_lesson
    @lesson = @course.lessons.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:title, :description, :position, :video_key, :duration_seconds, :max_views, :video)
  end
end
