# frozen_string_literal: true

desc "List all stats"
command :stats do |stats|
  stats.action do
    puts "Total activities: #{@introvert.total_activities}"
    puts "Total friends: #{@introvert.total_friends}"
    puts "Total locations: #{@introvert.total_locations}"
    puts "Total notes: #{@introvert.total_notes}"
    puts "Total tags: #{@introvert.total_tags}"
    days = @introvert.elapsed_days
    puts "Total time elapsed: #{days} day#{'s' if days != 1}"
  end
end
