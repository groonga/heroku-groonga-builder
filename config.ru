# -*- ruby -*-

application = lambda do |env|
  [200, {"Content-Type" => "text/plain"}, ["Groonga builder"]]
end
run application
