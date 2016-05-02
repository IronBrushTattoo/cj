require 'cj-parser'

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
