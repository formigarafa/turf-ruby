# frozen_string_literal: true

require "json"

def underscore(camel_cased_word)
  return camel_cased_word.to_s.dup unless /[A-Z-]|::/.match?(camel_cased_word)

  word = camel_cased_word.to_s.gsub("::", "/")
  # word.gsub!(inflections.acronyms_underscore_regex) { "#{$1 && '_' }#{$2.downcase}" }
  word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
  word.tr!("-", "_")
  word.downcase!
  word
end

def print_updated_checklist
  `curl -O https://raw.githubusercontent.com/Turfjs/turf-www/refs/heads/master/versioned_sidebars/version-7.2.0-sidebars.json`
  code_items = JSON.parse(File.read("version-7.2.0-sidebars.json"))["apiSidebar"]

  constants = code_items.find { |i| i["label"] == "Constants" }
  api_items = code_items.select { |i| i["label"] != "Constants" && i["label"] != "Type Definitions" }

  api_items.each do |i|
    puts "### #{i['label']}\n"
    i["items"].each do |f|
      fname = underscore(f.split("/").last)
      ok = "x"
      begin
        Turf.send(fname, "x")
      rescue Turf::NotImplementedError
        ok = " "
      rescue StandardError
        nil
      end

      puts "- [#{ok}] #{fname}"
    end
    puts "\n"
  end

  i = constants
  puts "### #{i['label']}\n"
  i["items"].each do |f|
    cname = underscore(f.split("/").last).upcase
    ok = " "
    if Turf.const_defined?(cname)
      ok = "x"
    end

    puts "- [#{ok}] #{cname}"
  end
  puts "\n"
end
