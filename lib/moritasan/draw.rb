require 'moritasan/draw/version'
require 'moritasan/draw/cli'

require 'logger'
require 'dotenv'
require 'oauth'
require 'json'

module Moritasan
  module Draw
    class Mukuchi
      # API url
      SCHEME = 'https'
      HOST = 'api.twitter.com'
      API_VER = '1.1'
      TMP = "#{SCHEME}://#{HOST}/#{API_VER}/"

      # Endpoint
      TWEET = "#{TMP}statuses/update.json"

      def initialize
        @l = Logger.new(STDOUT)
        @l.level = Logger::DEBUG

        d

        Dotenv.load
        consumer = OAuth::Consumer.new(
          ENV['CONSUMER_KEY'],
          ENV['CONSUMER_SECRET'],
          site:'https://api.twitter.com'
        )
        @token = OAuth::AccessToken.new(
          consumer,
          ENV['ACCESS_TOKEN'],
          ENV['ACCESS_TOKEN_SECRET']
        )
      end

      # Posted tweet
      def tweet(tweet)
        d
        @l.info("Tweet: #{tweet}")
        res = @token.request(:post, TWEET, status: tweet)
        if res.code == '200'
          @l.info(res.code)
        else
          @l.warn(res.body)
        end
        res.code
      end

      # Debug method
      def d
        @l.debug(caller[0][/`([^']*)'/, 1])
      end
    end
  end
end
