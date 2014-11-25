require 'thor'
require 'yaml'
require 'pp'

module Moritasan
  module Draw

    class CLI < Thor

      THEME_YML = 'theme.yml'
      PHRASE_YML = 'phrase.yml'

      desc 'stream', 'Stream'
      def stream
        m = Mukuchi.new
        m.d

        m.stream
      end

      option :tweet, aliases:'-t', required: true, desc:'Tweet TWEET'
      desc 'tweet', 'Tweet original TWEET'
      def tweet
        m = Mukuchi.new
        m.d

        m.tweet(options[:tweet])
      end

      option :phraserow, aliases:'-p', desc:'Tweet phrase'
      option :interactive, aliases:'-i', type: :boolean, default: false, desc:'Select phrase by interactive mode'
      desc 'tweetphrase', 'Tweet fixed phrase from phrase.yml'
      def tweetphrase
        m = Mukuchi.new
        m.d

        phrase_array = load_yaml(PHRASE_YML)

        if options[:interactive]
          puts 'Please select index you want to tweet'
          phrase_array.each.with_index(1) do |v, i|
            puts "#{i}: #{v}"
          end

          while true
            selected = STDIN.gets.chomp!.to_i
            if selected <= phrase_array.length
              break
            else
              puts 'Out of range'
            end
          end

          tw = phrase_array[selected - 1]
        else
          row = options[:phraserow].to_i
          if row == 0
            puts "ERROR phrase -p [PHRASEROW] (NOT array index)"
            exit 1
          else
            if row <= phrase_array.length
              tw = phrase_array[row - 1]
            else
              puts 'ERROR Out of range'
              exit 1
            end
          end
        end

        m.tweet(tw)
      end

      option :run, aliases:'-r', default: false, type: :boolean, desc:'Run tweet theme(DEFAULT: dryrun)'
      desc 'tweettheme', 'Tweet themed tweet from theme.yml'
      def tweettheme
        m = Mukuchi.new
        m.d

        theme = load_yaml(THEME_YML)

        # Random number
        max_length = theme['themes'].length
        index = rand(max_length)

        # Concat theme pre + suf
        th = theme['themes'][index]['theme']
        tw = theme['words']['prefix'] + th + theme['words']['suffix']

        if options[:run]
          # Update count and last_update
          count = theme['themes'][index]['count']
          count += 1
          theme['themes'][index]['count'] = count

          last_updated = Time.now.to_i
          theme['themes'][index]['last_updated'] = last_updated

          write_yaml(THEME_YML, theme)

          m.tweet(tw)
        else
          puts 'DRYRUN, please add -r or --run option if you want to RUN'
          puts tw
          exit 0
        end
      end

      option :id, aliases:'-i', required: true, desc:'Delete tweet id'
      desc 'tweetdel', 'Delete tweet by id'
      def tweetdel
        m = Mukuchi.new
        m.d

        m.delete_tweet(options[:id])
      end

      option :theme, aliases:'-t', required: true, desc:'Add theme'
      desc 'themeadd', 'Add theme to theme.yml'
      def themeadd
        theme = load_yaml(THEME_YML)
        arg = options[:theme]

        # Duplicate is exit
        if duplicate_theme(theme, arg)
          exit 1
        else
          add_theme = { 'theme' => arg, 'count' => 0, 'last_updated' => Time.now.to_i }
          puts "Add theme: #{add_theme}"
          theme['themes'] << add_theme

          write_yaml(THEME_YML, theme)
        end
     end

      option :theme, aliases:'-t', required: true, desc:'Delete theme'
      desc 'themedel', 'Delete theme to theme.yml'
      def themedel
        theme = load_yaml(THEME_YML)
        arg = options[:theme]

        # Duplicate is delete
        if duplicate_theme(theme, arg)
          theme['themes'].each do |t|
            if t.has_value?(arg)
              puts "Delete theme: #{t}"
              theme['themes'].delete(t)
            end
          end

          write_yaml(THEME_YML, theme)
        end
      end

      option :word, aliases:'-w', required: true, desc:'search word'
      desc 'themert', 'Search tweet and retweet'
      def themert
        m = Mukuchi.new
        m.d

        m.search_and_retweet(options[:word])
      end

      desc 'favshow', 'Show favolite tweets'
      def favshow
        m = Mukuchi.new
        m.d

        m.favolites
      end

      option :id, aliases:'-i', required: true, desc:'Tweet id'
      desc 'fav', 'Favolite tweet'
      def fav
        m = Mukuchi.new
        m.d

        m.favolite(options[:id])
      end

      option :id, aliases:'-i', required: true, desc:'Tweet id'
      desc 'favdel', 'Unfavolite tweet'
      def favdel
        m = Mukuchi.new
        m.d

        m.unfavolite(options[:id])
      end

      no_tasks do
        def load_yaml(file)
          YAML.load_file(file)
        end

        def write_yaml(file, theme)
          open(file, 'w') do |e|
            YAML.dump(theme, e)
          end
        end

        # Check duplicate
        def duplicate_theme(theme, arg)
          theme['themes'].each do |t|
            if t.has_value?(arg)
              puts "Duplicate theme: #{arg}"
              return true
            end
          end
          return false
        end
      end
    end
  end
end
