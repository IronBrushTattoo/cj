#!/usr/bin/ruby

require 'csv'
require 'json'
require 'chronic'
require './lib/sheet.rb'
require './lib/label.rb'

# write to take in xml file
csv_file = ARGV[0]
$days = ARGV[1].to_f

$cj_path = Dir.pwd()
$pdf_path = "#{$cj_path}/pdfs"
$templates_path = "#{$cj_path}/lib/templates"
$template_top = File.open("#{$templates_path}/template-top.txt").readlines
$template_bottom = File.open("#{$templates_path}/template-bottom.txt").readlines

$sheets_dir = "#{$pdf_path}/sheets"
$labels_dir = "#{$pdf_path}/labels"
$sheet_top = File.open("#{$templates_path}/labelsTemplate-top.txt").readlines


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
    
    columns = Label.new("#{size[0]}g",
                         "#{size[1]}\"",
                         row[2].gsub("&", "and").gsub("BZ", "Blue Zircon"),
                         row[1].to_s.split(/-/)[0],
                         row[4].to_s.split(".")[0],
                         row[5],
                         updated.to_f
                        )
    
    unless row[1] == "CASE JEWELRY-CJ"
      unless row[1] == "Product ID"
        if (Time.now.to_f - updated.to_f) < 60*60*24*$days
          puts columns.id
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

  get_rows(file).each do |row|

    puts row.id
    
    tex_file = "#{row.id}.tex"
    pdf_file = "#{row.id}.pdf"

    unless row.size == "\""
      size = "#{row.gauge} #{row.size}"
    else
      size = "#{row.gauge}"
    end

    type = row.desc
    id = row.id
    price = row.price

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

Sheets.make_sheets(csv_file)

puts "done!"
