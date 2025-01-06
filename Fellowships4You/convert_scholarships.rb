#!/usr/bin/env ruby
require 'json'

# Define tag mappings (copied from seeds.rb)
GEOGRAPHIC_TAGS = {
  '🇬🇧' => 'united_kingdom',
  '🇺🇸' => 'united_states',
  '🇨🇳' => 'china',
  '🇯🇵' => 'japan',
  '🇮🇪' => 'ireland',
  '🇩🇪' => 'germany',
  '🇮🇳' => 'india',
  '🌍' => 'africa',
  '🌏' => 'asia',
  '🌎' => 'latin_america',
  '🌐' => 'global'
}

FIELD_TAGS = {
  '🧑‍🔬' => 'stem',
  '⚕️' => 'medical',
  '⚖️' => 'law',
  '🗽' => 'social_justice',
  '✌️' => 'peace_studies',
  '🛡' => 'security_studies',
  '💰' => 'financial',
  '🥖' => 'food_security',
  '🎵' => 'music',
  '🗣' => 'language'
}

def extract_tags(name)
  tags = []
  
  # Extract geographic tags
  GEOGRAPHIC_TAGS.each do |emoji, tag|
    tags << tag if name.include?(emoji)
  end
  
  # Extract field tags
  FIELD_TAGS.each do |emoji, tag|
    tags << tag if name.include?(emoji)
  end
  
  tags
end

# Read the seeds.rb file
seeds_content = File.read('seeds.rb')

# Extract the scholarships array using regex
scholarships_str = seeds_content.match(/scholarships = \[(.*?)\]/m)[1]

# Convert Ruby hash syntax to JSON-compatible format
scholarships_str.gsub!(/(\w+):/, '"\1":')

# Evaluate the scholarships array in a safe context
scholarships = eval("[#{scholarships_str}]")

# Convert scholarships to JSON format
json_scholarships = scholarships.map do |scholarship|
  {
    name: scholarship[:name],
    description: scholarship[:description],
    url: scholarship[:url],
    dueDate: scholarship[:due_date],
    value: scholarship[:value],
    tags: extract_tags(scholarship[:name])
  }
end

# Create the final JSON structure
json_output = {
  scholarships: json_scholarships
}

# Write to scholarships.json
File.write('scholarships.json', JSON.pretty_generate(json_output))

puts "Successfully converted #{json_scholarships.length} scholarships to scholarships.json" 