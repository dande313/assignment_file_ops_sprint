class DictionaryUI

  def run
    @load= DictionaryLoader.new
    @search= DictionarySearcher.new
    @save= ResultsSaver.new
    loop do
      @load.load_dict
      @search.search_param
      @search.process_search
      @save.save_results
    end
  end
end

class DictionaryLoader
  def load_dict
    $results = []
    $dictionary = IO.readlines('5desk.txt')
    $dictionary.each do |word|
      word.strip!
    end
    puts "\e[H\e[2J"
    puts "Dictionary loaded"
    puts "Your dictionary contains #{$dictionary.count} words."
    puts ""
    puts "Number of words per starting letter:"
    letter_count=Hash.new(0)
    $dictionary.each do |word|
      word.split
      letter_count[word[0]] += 1
    end
    letter_count.each do |letter, count|
      puts "#{letter}: #{count}"
    end
  end
end

class DictionarySearcher
  def search_param
    @type= 0
    while @type== 0 do
      puts "\e[H\e[2J"
      puts "What type of search do you wish to perform?"
      puts "1. Exact "
      puts "2. Partial"
      puts "3. Begins With"
      puts "4. Ends With"
      puts '"q" will exit the program'
      @type= gets.chomp
      if @type== "q"
        exit
      else
        @type= @type.to_i
      end
      if @type < 1 || @type > 4
        puts "ERROR"
        gets
        search_param
      end
      puts ""
      puts "Enter the search term:"
      $term=gets.chomp
    end
  end

  def process_search
    if @type== 1
      @part_results= find_match(/\b#{$term}\b/).join(", ")
    elsif @type== 2
      @part_results= find_match(/#{$term}/).join(", ")
    elsif @type== 3
      @part_results= find_match(/\A#{$term}.+/).join(", ")
    elsif @type== 4
      @part_results= find_match(/#{$term}$/).join(", ")
    end
    $results<< @part_results
    puts "#{$results}"
  end

  def find_match(regex)
    $dictionary.select{ |word| word.match(regex)}
  end
end


class ResultsSaver
  def save_results
    puts "Would you like to save your results as a text file? y/n? 'q' quits."
    answer=gets.chomp
    if answer.downcase== "q"
      exit
    elsif answer.downcase== "y"
      puts "What would you like to call your results?"
      filename= gets.chomp
        if File.file?(filename)
          puts "The file #{filename} already exists. Overwrite? y/n"
          overwrite= gets.chomp
          if overwrite== "y"
            File.open(filename, 'w') {|f| f.write($results) }
            puts "#{filename} saved."
            gets
          else
            save_results
          end
        else
          File.open(filename, 'w') {|f| f.write($results) }
          puts "#{filename} saved."
          gets
        end
    elsif answer.downcase== "n"
      puts "not saved"
      gets
    else
      puts "ERROR: Invalid response"
      gets
      save_results
    end
  end
end

dict_reader= DictionaryUI.new
dict_reader.run
