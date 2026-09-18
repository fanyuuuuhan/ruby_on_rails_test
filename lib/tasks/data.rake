namespace :data do
  desc "Add existing data to the first user"
  task backfill_task_users: :environment do
    user = User.find_or_create_by!(email: "user@example.com") do |first_user|
      first_user.name = "John Doe"
    end
    update_count = Task.where(user_id: nil).update_all(user_id: user.id)
    puts "Updated #{update_count} tasks with user ID #{user.id}"
  end
end