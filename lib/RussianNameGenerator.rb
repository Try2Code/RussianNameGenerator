require 'facets/random.rb'
require 'json'

class RussianNameGenerator
  VALID_ETHNICS = %w[slav tur polsk]

  def initialize
    # readin the stuff and filter a bit
    system('pwd')
    firstnames = JSON.load(File.open('data/names.jsonl').read)
    midnames   = JSON.load(File.open('data/midnames.jsonl').read)
    surnames   = JSON.load(File.open('data/surnames.jsonl').read)

    # filters all names to make sure, all have the 'gender' attribute
    @firstnames = firstnames.select {|k,v| v.has_key?('gender') and \
                                     ('m' == v['gender'] or 'f' == v['gender'])}.select {|k,v| 
      ( v.has_key?('ethnic') and  ((VALID_ETHNICS - v['ethnic']).size < VALID_ETHNICS.size) ) or not v.has_key?('ethnic') }
    @midnames   = midnames.select   {|k,v| v.has_key?('gender')}
    @surnames   = surnames.select   {|k,v| v.has_key?('gender')}

    [@firstnames, @midnames, @surnames]
  end

  private
  def getRandom(ethnic)
    # filter for certain ethnic if given and not equal to :all
    if 'ALL' != ethnic then
      firstnames = @firstnames.select {|k,v| v.has_key?('ethnic') and v['ethnic'].include?(ethnic)}
    else
      firstnames = @firstnames
    end
    # select random firstname
    firstname = firstnames.rand_value
    firstnameText, gender = firstname['text'], firstname['gender']

    # select randome midname with proper gender
    midnameText = (@midnames.select {|k,v| gender == v['gender']}.rand_value)['text']

    # select random lastname proper gender
    lastname = @surnames.select {|k,v| gender == v['gender'] or 'u' == v['gender']}.rand_value
    lastnameText = (lastname['gender'] == gender or lastname['gender'] == 'u') ? lastname['text'] : lastname["#{gender}_form"]

    [firstnameText,midnameText,lastnameText,"(#{gender})"]
  end

 
  public
  def print(num=10,ethnic='ALL')
    num.times do
      puts getRandom(ethnic).join('|')
    end
  end
end
