class Admin::CoursesController < Admin::BaseController
  before_action :set_course, only: [:edit, :update, :destroy]

  def index
    @pagy, @courses = pagy(Course.order(created_at: :desc))
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to admin_courses_path, notice: "Course created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @course.update(course_params)
      redirect_to admin_courses_path, notice: "Course updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy!
    redirect_to admin_courses_path, notice: "Course deleted."
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :price, :status, :exam_category, :duration_days, :thumbnail)
  end
end
