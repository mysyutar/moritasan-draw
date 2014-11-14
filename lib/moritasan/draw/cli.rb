require 'thor'

module Moritasan
  module Draw

    class CLI < Thor

      desc 'tweet TWEET', 'Tweet to Twitter'
      option :tweet, aliases:'-t', default:true, desc:'Tweet contents'
      def tweet
        m = Mukuchi.new
        m.d
        puts options[:tweet]
        m.tweet(options[:tweet])
      end

      no_tasks do
      end
    end
  end
end
