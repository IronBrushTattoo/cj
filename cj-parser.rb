#!/usr/bin/ruby

require 'csv'
require 'json'
require 'chronic'
require './lib/sheet.rb'
require './lib/label.rb'

# write to take in xml file
csv_file = ARGV[0]

$cj_path = Dir.pwd()
$pdf_path = "#{$cj_path}/pdfs"
$templates_path = "#{$cj_path}/upc/lib/templates"
$template_top = File.open("#{$templates_path}/template-top.txt").readlines
$template_bottom = File.open("#{$templates_path}/template-bottom.txt").readlines

$sheets_dir = "#{$pdf_path}/sheets"
$labels_dir = "#{$pdf_path}/labels"
$sheet_top = File.open("#{$templates_path}/labelsTemplate-top.txt").readlines

$days = ARGV[1].to_f

# def get_sheet_rows
#     puts "gettting sheet rows"
  
#   Dir.chdir($pdf_path)
  
#   files = Dir.entries(".").reject { |entry| File.directory?(entry) }
#   $pdfs = files.select { |file| file.end_with? '.pdf' }
#   label_count = $pdfs.count

#   fboxs = []
  
#   $pdfs.each do |pdf|
#     fboxs.push "\\framebox[1.0\\width]{\\includegraphics{#{$labels_dir}/#{pdf}}}"
#   end
  
#   rows = fboxs.each_slice(4).to_a
#   return rows
# end

def get_sheets

  puts "getting sheets"
  
  pages = []

  Sheets.get_sheet_rows.each do |row|
    pages.push row
  end
  
  sheets = pages.each_slice(8).to_a

  return sheets
end

def get_rows(file)
  puts "getting rows"
  
  rows = []
  
  CSV.foreach(
    file,
    headers: false,
    skip_blanks: true,
    skip_lines: Regexp.union([ /^(?:,\s*)+$/, /^(?:Product)/ ]) ) do |row|
    
    size = row[5].to_s.gsub(/"/, '').gsub(/g/, '').gsub(/G/, '').gsub(/,/, '').split(' ')
    updated = Chronic.parse(row[10])
    
    columns = {
      "gauge" => "#{size[0]}g",
      "size" => "#{size[1]}\"",
      "desc" => row[2].gsub("&", "and").gsub("BZ", "Blue Zircon"),
      "id" => row[1].to_s.split(/-/)[0],
      "price" => row[4].to_s.split(".")[0],
      "supply" => row[5],
      "updated" => updated.to_f
    }

    
    
    unless row[1] == "CASE JEWELRY-CJ"
      unless row[1] == "Product ID"
        if (Time.now.to_f - updated.to_f) < 60*60*24*$days
          puts columns["id"]
          rows.push columns
        end
      end
    end
  end

  return rows

end

def rows_to_json(file)

  puts "converting rows to javascript object notation"

  json_file = "cj_db.json"
  count = get_rows(file).size

  File.open(json_file, "w") do |file|
    file.puts '{ "products": ['
  end
  
  get_rows(file).each_with_index do |row, index|
    File.open(json_file, "a") do |json|
      json.puts row.to_json

      unless index == count - 1
        json.puts ","
      end
    end
  end

  File.open(json_file, "a") do |file|
    file.puts '] }'
  end
end

def rows_to_tex(file)

  puts "converting rows to tex"
  get_rows(file).each do |row|

    tex_file = "#{row["id"]}.tex"
    pdf_file = "#{row["id"]}.pdf"
    unless row['size'] == "\""
      size = "#{row['gauge']} #{row['size']}"
    else
      size = "#{row['gauge']}"
    end
    type = row["desc"]
    id = row["id"]
    price = row["price"]

    File.open(tex_file, "w") do |file|
      pre_script = "{\\scriptsize\\textit{"
      pre_lg = "{\\large"
      pre_LG = "{\\Large"
      post = "}}\n\n"

      file.puts $template_top

      file.puts "\\begin{center}" +
                "#{pre_lg}{" +
                "#{type}#{post}" +
                "\\end{center}"

      file.puts "\\begin{center}" +
                "#{pre_LG}" + "\\textit{" +
                "#{size}#{post}" +
                "\\end{center}"
      
      file.puts "\\begin{center}" +
                "#{pre_lg}{" +
                "#{id}\\hspace{25mm}  \\#{price}#{post}" +
                "\\end{center}"

      file.puts $template_bottom
    end

    `pdflatex #{tex_file} && mv *.tex *.aux *.log *.out tmp && mv *.pdf #{$pdf_path}`
  end
end

def make_sheets(file)
  rows_to_json(file)
  rows_to_tex(file)

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

make_sheets(csv_file)
