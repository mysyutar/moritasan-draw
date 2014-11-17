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
        #@l = Logger.new('logs/tweet.log')
        @l.level = Logger::INFO

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
        res_code = res.code.to_i
        @l.info("Status code: #{res_code}")

        case res_code
        when 200
          @l.info('Success')
        else
          body = JSON.load(res.body)
          code = body['errors'][0]['code']
          # Retry if duplicate
          if code == 187
            @l.warn(body)
            # @l.warn('Retry')
          else
            @l.warn(body)
          end
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
