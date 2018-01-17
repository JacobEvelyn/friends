# frozen_string_literal: true

desc "List all stats"
command :stats do |stats|
  stats.action do
    @introvert.stats
  end
end
