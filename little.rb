
require 'cj-parser'

cj_file = ARGV[0].to_s
days = ARGV[1]


Shoes.app(title: "Case Jewelry Label Maker", width: 800, height: 1000, resizable: true) {
  background "#c3f4f8".."#fff"
  fill white
  border("#fff",
         strokewidth: 4)
  
  stack(margin: 12) do
    para "Number of Days"
    flow {
      #@days = edit_line :width => 50
      @days_para = para "0"

      button "Choose File" do
        @file = ask_open_file
      end

      button "#{@days_para} Days" do
        @days = ask("How many days back?")
        #animate do
          @days_para.replace "#{@days}"
        #end
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

    @sheet = image(
      #"img/label.png",
      "img/sheet.png",
      width: 850,
      height: 1100
    )

  end
}
