require 'open3'
require 'base64'

# Can be changed to podman for rootless containers
program =
  case ENV["DOCKER_PROGRAM"]
  when "podman" then "podman"
  else "docker"
  end

# Whitelist of valid extensions
extnames = {
  ".gif"  => ".gif",
  ".jpg"  => ".jpg",
  ".jpeg" => ".jpeg",
  ".png"  => ".png",
  ".svg"  => ".svg",
  ".webm" => ".webm",
  ".webp" => ".webp",
  ".mp4"  => ".mp4"
}

# Set unknown extensions to empty string instead of using them
extnames.default = ""

# Get the name of the program to invoke
progname = ARGV.shift

# Generate replacements list (files that need to be written/read from the container)
# Format is in 2-tuples [container_name, host_name]
replacements = []
counter      = -1

args = ARGV.map do |arg|
  if arg.start_with?("/") && File.exists?(arg)
    ext     = extnames[File.extname(arg).downcase]
    newname = "#{counter += 1}#{ext}"

    replacements.push [newname, arg]

    newname
  else
    arg
  end
end

exit_status = 255
program_stdout = ""
program_stderr = ""

Open3.popen2(
  program,
  "exec",
  "-i",
  "fiberglass_container",
  "ruby",
  "/opt/input.rb"
) do |stdin, stdout|
  # Generate invocation. Note that arguments are passed to the container over
  # stdin so as to avoid any potential host side shell argument parsing.
  #
  # [base64 progname]
  # [base64 arg1],[base64 arg2],...
  # <0.png>:[base64 contents 0.png]
  # ...

  # Write progname
  stdin.write Base64.strict_encode64(progname)
  stdin.write "\n"

  # Write arguments
  args.each do |arg|
    stdin.write Base64.strict_encode64(arg)
    stdin.write ","
  end
  stdin.write "\n"

  # Write file replacements
  replacements.each do |name, file|
    stdin.write name
    stdin.write ":"
    stdin.write Base64.strict_encode64(File.read(file))
    stdin.write "\n"
  end

  stdin.flush
  stdin.close

  # Read response.
  #
  # [exit status]
  # [base64 stdout]
  # [base64 stderr]
  # [base64 contents 1.png]
  # ...

  stdout.each_line.with_index do |line, index|
    line.chomp!

    if index == 0
      exit_status = line.to_i
      next
    end

    if index == 1
      program_stdout = Base64.strict_decode64(line)
      next
    end

    if index == 2
      program_stderr = Base64.strict_decode64(line)
      next
    end

    target_file = replacements[index - 3][1]
    File.write(target_file, Base64.strict_decode64(line))
  end

  stdout.close
end

$stdout.write program_stdout
$stderr.write program_stderr
exit exit_status
