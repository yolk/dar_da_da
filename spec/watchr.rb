# Run me with:
#
#   $ watchr specs.watchr.rb

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------

def run(files)
  files = Array(files).reject do |file|
    skip = !File.exist?(file)
    puts "*** #{file} skipped - does not exist!" if skip
    skip
  end
  
  if files.any?
    cmd = "spec -c #{files.join(' ')}"
    puts("*** Executing #{cmd}")
    system(cmd)
  end
end

def run_all_tests
  puts "\n***** Running all tests *****\n"
  cmd = Dir['spec/**/*_spec.rb']
  run(cmd)
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( '^lib/(.*)\.rb'         )   { |m| run( "spec/%s_spec.rb" % m[1] ) }
watch( '^lib/(.*)/(.*)\.rb'      )   { |m| run( "spec/#{m[1]}/#{m[2]}_spec.rb" ) }
watch( '^spec/(.*)_spec\.rb' )   { |m| run( "spec/%s_spec.rb" % m[1] ) }
watch( '^spec/spec_helper\.rb' )   { run_all_tests }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  run_all_tests
end

# Ctrl-C
Signal.trap('INT') { abort("\n") }

puts "*** Watching for changes..."