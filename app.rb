require 'bundler/setup'
require 'sinatra'
require 'yaml/store'
require 'yaml'
require 'json'
require 'date'

module Phy
  BASEURL = 'www.phy.cuhk.edu.hk/course'

  def self.gen_url(year, sem, data)
    magic = ''
    if data.has_key? 'password'
      magic = "#{data['name']}:#{data['password']}@"
    end

    "http://#{magic}#{BASEURL}/#{year}/#{sem}/#{data['course']}/download/index.html"
  end
end

def djb2(word)
  word.each_codepoint.reduce(5381) do |prev, code|
    ((prev << 5) + prev) + code;
  end
end

QA_STORE = YAML::Store.new 'QA.yml'
COURSE_STORE = YAML::Store.new 'courses.yml'

before do
  # Strip the last / from the path
  request.env['PATH_INFO'].gsub!(/\/$/, '')
end

get '' do
  @groups = COURSE_STORE.transaction { COURSE_STORE['groups'] }
  erb :index
end

get '/edit.html' do
  groups = "---\n"
  # handle the case of corrupted yaml database gracefully
  begin
    groups = COURSE_STORE.transaction { COURSE_STORE['groups'] }
    @config = groups.to_yaml
  rescue YAML::Store::Error
  end
  erb :edit
end

post '/submit_edit' do
  all_qa = QA_STORE.transaction { QA_STORE['QA'] }
  if not djb2(params["answer"]) == all_qa[0]['A']
    return "wrong"
  end

  COURSE_STORE.transaction do
    begin
      config = YAML.load params["config"]
      COURSE_STORE['groups'] =  config
    rescue Psych::SyntaxError
      return "parse error"
    end
  end

  "ok"
end

get '/ajaxQA' do
  all_qa = QA_STORE.transaction { QA_STORE['QA'] }
  JSON.generate(all_qa[0])
end
