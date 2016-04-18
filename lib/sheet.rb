module Sheets
  def Sheets.get_sheet_rows()
    puts "getting sheet rows"
  
    Dir.chdir($pdf_path)
  
    files = Dir.entries(".").reject { |entry| File.directory?(entry) }
    $pdfs = files.select { |file| file.end_with? '.pdf' }
    label_count = $pdfs.count

    fboxs = []
  
    $pdfs.each do |pdf|
      fboxs.push "\\framebox[1.0\\width]{\\includegraphics{#{$labels_dir}/#{pdf}}}"
    end
  
    rows = fboxs.each_slice(4).to_a
    return rows
  end
end
