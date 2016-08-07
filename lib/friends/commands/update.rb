# frozen_string_literal: true

desc "Updates the `friends` program"
command :update do |update|
  update.action do
    # rubocop:disable Lint/AssignmentInCondition
    if match = `gem search friends`.match(/^friends\s\(([^\)]+)\)$/)
      # rubocop:enable Lint/AssignmentInCondition
      remote_version = match[1]
      if Semverse::Version.coerce(remote_version) >
         Semverse::Version.coerce(Friends::VERSION)
        `gem update friends && gem cleanup friends`
        @message = if $?.success?
                     Paint[
                       "Updated to friends #{remote_version}", :bold, :green
                     ]
                   else
                     Paint[
                       "Error updating to friends version #{remote_version}", :bold, :red
                     ]
                   end
      else
        @message = Paint[
          "Already up-to-date (#{Friends::VERSION})", :bold, :green
        ]
      end
    end
  end
end
