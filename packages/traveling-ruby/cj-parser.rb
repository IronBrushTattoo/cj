#!/usr/bin/env ruby

require 'json'
require 'chronic'
require 'rubyXL'
require 'docx'
require 'roo'

require 'lib/sheets.rb'
require 'lib/label.rb'
def set_variables(days)

  $days = days.to_f
  
  $cj_path = Dir.pwd()
  $pdf_path = "#{$cj_path}/pdfs"
  $templates_path = "#{$cj_path}/lib/templates"
  $template_top = File.open("#{$templates_path}/template-top.txt").readlines
  $template_bottom = File.open("#{$templates_path}/template-bottom.txt").readlines

  $sheets_dir = "#{$pdf_path}/sheets"
  $labels_dir = "#{$pdf_path}/labels"
  $sheet_top = File.open("#{$templates_path}/labelsTemplate-top.txt").readlines

end
def strip(s)
  s.gsub(/"/, '').
    gsub(/g/, '').
    gsub(/G/, '').
    gsub(/,/, '').
    split(' ')
end

def nil_convert(c)
  if c.nil?
    ""
  else
    c
  end
end

def get_labels(file)
  puts "getting labels"
  
  labels = []
  
  xls_file = Roo::Spreadsheet.open(file)

  xls_file.sheets.each do |sheet|

    sheet = xls_file.sheet(sheet)
    
    sheet.parse[4..-1].each do |row|

      zero,one,two,four,five,ten = nil_convert(row[0]),
      nil_convert(row[1]),
      nil_convert(row[2]),
      nil_convert(row[4]),
      nil_convert(row[5]),
      nil_convert(row[10])

      sizes = strip(five.to_s)
      gauge = "#{sizes[0]}g"
      size = "#{sizes[1]}\""
      desc = two.gsub("&", "and")
      id = one.to_s.split(/-/)[0]
      price = "$#{four.to_s.split(".")[0]}"
      supply = five
      updated = Chronic.parse(ten).to_f

      label = Label.new(gauge,
                        size,
                        desc,
                        id,
                        price,
                        supply,
                        updated
                       )

      seconds = 60*60*24*$days
      
      if (Time.now.to_f - updated.to_f) < seconds
        puts label.id
        $labelID = label.id
        labels.push label
      end

    end
  end

  # old csv code, keeping around for a rainy day
  # CSV.foreach(
  #   file,
  #   headers: false,
  #   skip_blanks: true,
  #   skip_lines: Regexp.union([ /^(?:,\s*)+$/, /^(?:Product)/ ]) ) do |row|

  #   size = row[5].to_s.gsub(/"/, '').gsub(/g/, '').gsub(/G/, '').gsub(/,/, '').split(' ')
  #   updated = Chronic.parse(row[10])

  #   label = Label.new("#{size[0]}g",
  #                        "#{size[1]}\"",
  #                        row[2].gsub("&", "and"),
  #                        row[1].to_s.split(/-/)[0],
  #                        row[4].to_s.split(".")[0],
  #                        row[5],
  #                        updated.to_f
  #                       )

  #   unless row[1] == "CASE JEWELRY-CJ"
  #     unless row[1] == "Product ID"
  #       if (Time.now.to_f - updated.to_f) < 60*60*24*$days
  #         puts label.id
  #         labels.push label
  #       end
  #     end
  #   end
  # end

  return labels

end
def rows_to_json(file)

  puts "converting rows to javascript object notation"

  json_file = "cj_db.json"
  count = get_labels(file).size

  File.open(json_file, "w") do |file|
    file.puts '{ "products": ['
  end
  
  get_labels(file).each_with_index do |row, index|
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
def labels_to_tex(file)

  get_labels(file).each do |row|

    puts row.id
    
    tex_file = "#{row.id}.tex"
    pdf_file = "#{row.id}.pdf"

    if row.size == "\""
      size = row.gauge
    elsif row.gauge == ""
      size = row.size
    else
      size = "#{row.gauge} #{row.size}"
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
