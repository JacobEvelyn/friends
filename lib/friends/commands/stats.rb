# frozen_string_literal: true

desc "List all stats"
command :stats do |stats|
  stats.action do
    puts "Total activities: #{@introvert.total_activities}"
    puts "Total friends: #{@introvert.total_friends}"
    days = @introvert.elapsed_days
    puts "Total time elapsed: #{days} day#{'s' if days != 1}"
  end
end
