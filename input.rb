require 'open3'
require 'base64'

# Container-side script. Can be more lax here.

progname = nil
args = []
files = []

# Parse input
$stdin.each_line.with_index do |line, index|
  if index == 0
    progname = Base64.strict_decode64(line)
    next
  end

  if index == 1
    args = line.split(",").map { |a| Base64.strict_decode64(a) }
    next
  end

  name, contents = line.split(":")
  files << name
  File.write(name, Base64.strict_decode64(contents))
end

# Run command
stdout, stderr, status = Open3.capture3(progname, *args)

# Generate output
$stdout.write status.exitstatus
$stdout.write "\n"

$stdout.write Base.strict_encode64(stdout)
$stdout.write "\n"

$stdout.write Base.strict_encode64(stderr)
$stdout.write "\n"

files.each do |file|
  $stdout.write Base.strict_encode64(File.read(file))
  $stdout.write "\n"
end
