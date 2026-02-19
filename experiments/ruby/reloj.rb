# archivo: reloj.rb
require 'time'

loop do
  print "\rHora actual: #{Time.now.strftime('%H:%M:%S')}"
  sleep 1
end
