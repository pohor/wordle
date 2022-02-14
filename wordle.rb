require 'bundler/inline'

gemfile do
  gem 'evolvable'
end

class CharacterGene
  include Evolvable::Gene

  CHARACTERS = ('a'..'z').to_a

  def to_s
    @to_s ||= CHARACTERS.sample
  end
end

class Wordle
  include Evolvable


  def self.call(
    string,
    population_size = 300,
    mutation_probability = 0.7,
    selection_size = 4
  )
    self.target = string
    self.max_string_length = string.length

    population = new_population(size: population_size)
    population.mutation.probability = mutation_probability
    population.selection.size = selection_size
    population.evolve(goal_value: max_string_length)
    p population.evolutions_count + 1
  end

  def self.max_string_length
    @max_string_length ||= 8
  end

  def self.max_string_length=(val)
    @max_string_length = val
  end

  def self.target=(val)
    @target = val.empty? ? ('a'..'z').to_a.sample(max_string_length).join : val
  end

  def to_s
    @to_s ||= genes.join
  end

  def self.target
    @target ||= ('a'..'z').to_a.sample(max_string_length).join
  end

  def self.search_space
    { characters: { type: 'CharacterGene', count: max_string_length } }
  end

  def self.before_evolution(population)
    best_evolvable = population.best_evolvable
    puts "#{population.evolutions_count + 1}. #{color_matches(best_evolvable)}"
  end

  def self.green(string)
    "\033[32m#{string}\033[0m"
  end

  def self.yellow(string)
    "\033[33m#{string}\033[0m"
  end

  def value
    @value ||= compute_value
  end

  def self.target
    @target ||= 'abcdefgh'
  end

  private

  def self.color_matches(best_string)
    result = {}
    best_string = best_string.to_s.chars
    best_string.each_with_index do |char, index|
      result[index.to_s] = if target[index] == char
                             [char, :green]
                           elsif target.chars.include?(char)
                             [char, :yellow]
                           else
                             [char, nil]
                           end
    end
    result.keys.map { |key| colored_char(result[key]) }.join
  end

  def self.colored_char(arr_with_instructions)
    color_char?(arr_with_instructions) ? send(arr_with_instructions[1], arr_with_instructions[0]) : arr_with_instructions[0]
  end

  def self.color_char?(arr_with_instructions)
    arr_with_instructions[1].is_a? Symbol
  end

  def genes_to_string
    @genes_to_string ||= find_genes(:characters)
  end

  def compute_value
    value = 0
    target = self.class.target
    genes_to_string.each_with_index do |gene, index|
      value += 1 if gene.to_s == target[index]
    end
    value
  end
end

class Array
  def median
    sorted = self.sort
    size = sorted.size
    center = size / 2

    if size.even?
      (sorted[center - 1] + sorted[center]) / 2.0
    else
      sorted[center]
    end
  end
end

sum = 0
results = []
1000.times { res = Wordle.call('qwertyui'); sum += res; results << res }
puts "average: #{sum/1000}"
puts "median: #{results.median}"
puts "min: #{results.min}"
puts "max: #{results.max}"
