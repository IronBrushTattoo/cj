
module Sheets

  def Sheets.get_sheet_rows()
    Dir.chdir($pdf_path)
    
    files = Dir.entries(".").reject { |entry| File.directory?(entry) }
    pdfs = files.select { |file| file.end_with? '.pdf' }
    label_count = pdfs.count

    fboxs = []
    
    pdfs.each do |pdf|
      fboxs.push "\\framebox[1.0\\width]{\\includegraphics{#{$labels_dir}/#{pdf}}}"
    end
    
    rows = fboxs.each_slice(4).to_a
    return rows
  end

  def Sheets.get_sheets()
    
    pages = []

    get_sheet_rows.each do |row|
      pages.push row
    end
    
    sheets = pages.each_slice(8).to_a

    return sheets
  end

  def Sheets.make_sheets(file)


    rows_to_json(file)
    labels_to_tex(file)

    sheet_count = get_sheets.count

    if sheet_count >= 1

      puts "creating sheets"
      
      sheets = get_sheets

      i = 0

      puts "entering sheets directory"
      Dir.chdir($sheets_dir)
      `mv *.pdf bak`
      
      sheets.each do |page|

        name = "sheet_000#{i}"
        filename = "#{name}.tex" 

        puts "making #{name} sheet"
        File.open(filename, "w") do |file|
          file.puts $sheet_top
          file.puts "\\begin{center}"
          file.puts "\\setlength{\\fboxsep}{1pt}"
          file.puts "\\setlength{\\fboxrule}{0.1pt}"
        end
        
        page.each do |row|
          File.open(filename, "a") do |file|
            
            file.puts row
            file.puts "\\newline"

            row.each do |box|
              pdf = box.split("{").last.split("}").first.split("/").last
              `mv ../#{pdf} #{$labels_dir}`
            end
          end
        end

        File.open(filename, "a") do |file|
          file.puts "\\end{center}"
          file.puts "\\end{document}"
        end

        i += 1
        
        #`pdflatex #{filename} && evince #{name}.pdf && mv *.aux *.log *.out *.tex texfiles`
        `pdflatex #{filename} && mv *.aux *.log *.out *.tex texfiles`
        
      end

    end

    Dir.chdir($cj_path)
    
  end

  
end
