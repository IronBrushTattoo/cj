<https://github.com/larsch/ocra>

<./Gemfile>

    source 'https://rubygems.org'
    
    ruby '2.2.3', :engine => 'jruby', :engine_version => '9.0.5.0'
    
    gem 'faker'
    gem 'json'
    gem 'chronic'
    gem 'roo', '~> 2.3.2'
    gem 'shoes-core', '~> 4.0.0.pre5'
    gem 'shoes-swt', '~> 4.0.0.pre5'
    
    group :development do
      gem 'rake'
    end

<./app.rb>

    #!/usr/bin/env jruby
    
    require 'cj-parser.rb'
    
    cj_file = ARGV[0].to_s
    days = ARGV[1]
    
    
    Shoes.app(title: "Case Jewelry Label Maker", width: 800, height: 1000, resizable: true) {
      #background "#c3f4f8".."#fff"
      #background "#000"
      background "img/sheet.png"
    
      @days_display = stack(margin: 12) do
        @days_para = para strong("0")
    
        @days_para
      end
    
      stack(margin: 12) do
        para "Number of Days"
        flow {
          #@days = edit_line :width => 50
    
          button "Choose File" do
            @file = ask_open_file
          end
    
          @days_button = button "Days" do
            @days = ask("How many days back?")
            @days_display.clear do
              @days_para = para strong(@days)
    
              @days_para
            end
          end
    
          button "Submit" do
            #alert "Making sheets from #{@file} from last #{@days.text} days"
            #alert "Making sheets from #{@file} from last #{@days} days"
            #set_variables(@days.text)
    
            if confirm("Make sheets from #{@file} from last #{@days} days?")
              set_variables(@days)
              Sheets.make_sheets(@file)
            end
          end
    
          button "X" do
            exit()
          end
        }
    
        # @sheet = image(
        #   #"img/label.png",
        #   "img/sheet.png",
        #   width: 850,
        #   height: 1100
        # )
    
      end
    }

    ocra app.rb

    /home/son/.rbenv/versions/jruby-9.0.5.0/lib/ruby/gems/shared/gems/ocra-1.3.6/bin/ocra:19: warning: already initialized constant ALT_SEPARATOR
    === Loading script to check dependencies

    LoadError: no such file to load -- cj-parser

    require at org/jruby/RubyKernel.java:937
    require at /home/son/.rbenv/versions/jruby-9.0.5.0/lib/ruby/stdlib/rubygems/core_ext/kernel_require.rb:54
     <top> at /home/son/IBT/jewelry/Retail_Jewelry/packages/ocra/app.rb:1
      load at org/jruby/RubyKernel.java:955
     <top> at /home/son/.rbenv/versions/jruby-9.0.5.0/lib/ruby/gems/shared/gems/ocra-1.3.6/bin/ocra:1
      load at org/jruby/RubyKernel.java:955
     <top> at /home/son/.rbenv/versions/jruby-9.0.5.0/bin/ocra:23
