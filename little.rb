
require 'cj-parser'

cj_file = ARGV[0].to_s
days = ARGV[1]

Shoes.app do
  background "#efc"
  border("#be8",
         strokewidth: 6)

  stack(margin: 12) do
    para "Number Days"

    flow do
      @days = edit_line
      @button = button "Submit"
      @button.click do
        set_variables(@days.text.to_i)
      end
    end

    flow do
      @file = edit_line
      @button = button "Submit"
      @button.click do
        #Sheets.make_sheets(@file)    
        #Sheets.make_sheets(cj_file)    
      end
    end
  end
end
