puts "Creating admin user..."
admin = User.find_or_create_by!(email: "admin@examprep.com") do |u|
  u.name = "Admin"
  u.password = "password123"
  u.role = :admin
end
puts "Admin: admin@examprep.com / password123"

puts "Creating sample courses with images..."
course_data = [
  { cat: "UPSC", price: 2499, img: "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&h=250&fit=crop" },
  { cat: "SSC",  price: 1499, img: "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&h=250&fit=crop" },
  { cat: "Banking", price: 1999, img: "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=250&fit=crop" },
  { cat: "Railways", price: 999, img: "https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=400&h=250&fit=crop" },
  { cat: "State PSC", price: 1799, img: "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400&h=250&fit=crop" }
]

course_data.each do |data|
  course = Course.find_or_create_by!(title: "#{data[:cat]} Complete Preparation 2025") do |c|
    c.description = "Comprehensive #{data[:cat]} exam preparation course with video lectures, practice questions, and study material. Covers all topics from the latest syllabus."
    c.price = data[:price]
    c.status = :published
    c.exam_category = data[:cat]
    c.duration_days = 365
    c.thumbnail_url = data[:img]
  end

  # Update image if course already existed
  course.update!(thumbnail_url: data[:img]) if course.thumbnail_url.blank?

  3.times do |i|
    course.lessons.find_or_create_by!(title: "#{data[:cat]} - Lesson #{i + 1}") do |l|
      l.description = "#{data[:cat]} preparation lesson #{i + 1} covering important topics."
      l.position = i + 1
      l.duration_seconds = [1800, 2700, 3600].sample
      l.max_views = 5
    end
  end
end

puts "Creating students with purchases..."
purchased_names = [
  "Rahul Sharma", "Priya Patel", "Amit Kumar", "Sneha Gupta", "Vikram Singh",
  "Anjali Verma", "Rohit Jain", "Neha Reddy", "Suresh Yadav", "Pooja Nair",
  "Karan Mehta", "Divya Iyer", "Arjun Das", "Meera Krishnan", "Sanjay Tiwari"
]

courses = Course.all.to_a

purchased_names.each_with_index do |name, i|
  user = User.find_or_create_by!(email: "student#{i + 1}@example.com") do |u|
    u.name = name
    u.password = "password123"
    u.phone = "98#{rand(10_000_000..99_999_999)}"
    u.role = :student
  end

  courses.sample(rand(1..3)).each do |course|
    next if user.enrollments.exists?(course: course)

    enrolled_at = rand(1..30).days.ago
    enrollment = Enrollment.create!(
      user: user, course: course, status: :active,
      amount_paid: course.price,
      enrolled_at: enrolled_at,
      expires_at: enrolled_at + course.duration_days.days
    )

    Payment.create!(
      user: user, enrollment: enrollment,
      razorpay_order_id: "order_#{SecureRandom.alphanumeric(14)}",
      razorpay_payment_id: "pay_#{SecureRandom.alphanumeric(14)}",
      razorpay_signature: SecureRandom.hex(32),
      amount: course.price, currency: "INR", status: :paid,
      created_at: enrolled_at
    )
  end
end

puts "Creating registered-but-not-purchased users..."
free_names = [
  "Deepak Chauhan", "Ritu Saxena", "Manish Pandey", "Kavita Joshi", "Nitin Agarwal",
  "Swati Mishra", "Rajesh Pillai", "Anita Bose", "Gaurav Sinha", "Lakshmi Menon"
]

free_names.each_with_index do |name, i|
  User.find_or_create_by!(email: "free_user#{i + 1}@example.com") do |u|
    u.name = name
    u.password = "password123"
    u.phone = "97#{rand(10_000_000..99_999_999)}"
    u.role = :student
  end
end

puts ""
puts "Seed complete!"
puts "  Users: #{User.count} (#{User.student.count} students, #{User.admin.count} admins)"
puts "  Not purchased: #{User.student.where.not(id: Enrollment.active.select(:user_id)).count}"
puts "  Courses: #{Course.count}"
puts "  Lessons: #{Lesson.count}"
puts "  Enrollments: #{Enrollment.count}"
puts "  Payments: #{Payment.count}"
puts "  Total Revenue: ₹#{Payment.paid.sum(:amount)}"
