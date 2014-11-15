require 'thor'
require 'yaml'
require 'pp'

module Moritasan
  module Draw

    class CLI < Thor

      option :phraserow, aliases:'-p', desc:'Tweet phrase'
      option :interactive, aliases:'-i', type: :boolean, default: false, desc:'Select phrase by interactive mode'
      desc 'phrase', 'Tweet fixed phrase from phrase.yml'
      def phrase
        m = Mukuchi.new
        m.d

        phrase_array = YAML.load_file('phrase.yml')

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

      option :theme, aliases:'-t', desc:'Tweet theme'
      desc 'theme', 'Tweet themed tweet from theme.yml'
      def theme
        m = Mukuchi.new
        m.d

        m.tweet(options[:tweet])
      end

      no_tasks do
      end
    end
  end
end
