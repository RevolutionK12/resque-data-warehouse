dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
$TESTING = true

require 'rubygems'
require 'test/unit'
require 'resque'
# gem 'activerecord', '=2.3.4'
require 'active_record'
# require 'active_record/fixtures'
# require 'active_support'
# require 'active_support/test_case'
# require 'after_commit' # only needed for ActiveRecord < 3

require 'resque-data-warehouse'
require dir + '/test_models'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'mysql']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])

load(File.dirname(__FILE__) + "/schema.rb")
##
# make sure we can run redis
if !system("which redis-server")
  puts '', "** can't find `redis-server` in your path"
  puts "** try running `sudo rake install`"
  abort ''
end

def get_redis_pid
  pid = `ps -e -o pid,command | grep [r]edis-test`.split(" ")[0]
  pid && pid.to_i
end

##
# start our own redis when the tests start,
# kill it when they end
at_exit do
  next if $!

  if defined?(MiniTest)
    exit_code = MiniTest::Unit.new.run(ARGV)
  else
    exit_code = Test::Unit::AutoRunner.run
  end

  puts "Killing test redis server..."
  Process.kill("KILL", get_redis_pid)
  exit exit_code
end

puts "Starting redis for testing at localhost:9736..."
`redis-server #{dir}/redis-test.conf`
pid = nil
10.times do
  break if pid
  pid = get_redis_pid
end
unless pid
  puts "Could not start redis"
  exit 1
end
Resque.redis = '127.0.0.1:9736'
Resque.redis.select 13
