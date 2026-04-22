class HomeController < ApplicationController
  def index
    @featured_courses = Course.published.limit(6)
  end
end
