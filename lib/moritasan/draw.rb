require 'moritasan/draw/version'
require 'moritasan/draw/cli'

require 'logger'
require 'dotenv'
require 'oauth'
require 'json'
require 'uri'

module Moritasan
  module Draw
    class Mukuchi
      # API url
      SCHEME = 'https'
      HOST = 'api.twitter.com'
      API_VER = '1.1'
      TMP = "#{SCHEME}://#{HOST}/#{API_VER}/"
      SUFFIX = '.json'

      # Endpoint
      RATE = "#{TMP}application/rate_limit_status#{SUFFIX}"
      TWEET = "#{TMP}statuses/update#{SUFFIX}"
      SEARCH = "#{TMP}search/tweets#{SUFFIX}"
      FAVLIST = "#{TMP}favorites/list#{SUFFIX}"
      FAV = "#{TMP}favorites/create#{SUFFIX}"
      UNFAV = "#{TMP}favorites/destroy#{SUFFIX}"
      # retweet/:id + SUFFIX
      RETWEET = "#{TMP}statuses/retweet/"
      # destroy/:id + SUFFIX
      DELETE = "#{TMP}statuses/destroy/"

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
        response_code(res)
      end

      def search_and_retweet(word)
        d
        @l.info("Search: #{word}")
        word = URI.encode(word)
        res = @token.request(:get, "#{SEARCH}?q=#{word}")
        response_code(res)

        JSON.load(res.body).each do |k,v|
          if k == 'statuses'
            v.reverse_each do |tweet|
              # Exclude Retweet
              if tweet['retweeted_status'].nil?
                id = tweet['id']
                name = tweet['user']['name']
                screen_name = tweet['user']['screen_name']
                text = tweet['text']

                @l.info("Retweet: #{screen_name} / #{name} - #{id} - #{text}")
                res = @token.request(:post, "#{RETWEET}#{id}.json")
                sleep rand(10)
                response_code(res)
              end
            end
          end
        end
      end

      def delete_tweet(id)
        d

        res = @token.request(:post, "#{DELETE}#{id}.json")
        response_code(res)
      end

      def favolites
        d

        res = @token.request(:get, "#{FAVLIST}")
        response_code(res)

        body = JSON.load(res.body)
        body.each do |k|
          @l.info(k['id'])
          @l.info(k['text'])
          @l.info(k['user']['screen_name'])
          unfavolite(k['id'])
          ran = rand(20)
          puts ran
          sleep ran
        end
      end

      def favolite(id)
        d

        res = @token.request(:post, "#{FAV}?id=#{id}")
        response_code(res)
      end

      def unfavolite(id)
        d

        res = @token.request(:post, "#{UNFAV}?id=#{id}")
        response_code(res)
      end

      # Debug method
      def d
        @l.debug(caller[0][/`([^']*)'/, 1])
      end

      def rate_limit(resource=nil)
        if resource.nil?
          rate = RATE
        else
          rate = "#{RATE}?resources=#{resource}"
        end

        res = @token.request(:get, rate)
        response_code(res)

        body = JSON.load(res.body)
        if resource.nil?
          pp body['resources']
        else
          pp body['resources'][resource]
        end
      end

      def response_code(res)
        res_code = res.code.to_i

        case res_code
        when 200
          @l.info("HTTP status code: #{res_code}")
        else
          @l.warn("HTTP status code: #{res_code}")

          body = JSON.load(res.body)
          code = body['errors'][0]['code']
          @l.warn("Twitter code: #{body}")
        end
        res.code
      end
    end
  end
end
