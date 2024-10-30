require 'find'
require 'json'
require 'open3'

def env_has_key(key)
  !ENV[key].nil? && ENV[key] != '' ? ENV[key] : abort("Missing #{key}.")
end

$output_path = env_has_key("AC_OUTPUT_DIR")
$repo_path = env_has_key("AC_REPOSITORY_DIR")
$npm_params = env_has_key("AC_RN_TEST_COMMAND_ARGS")

def run_command(command)
  puts "@@[command] #{command}"
  stdout_str = nil
  stderr_str = nil
  status = nil

  Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
    stdout.each_line { |line| puts line }
    stdout_str = stdout.read
    stderr_str = stderr.read
    status = wait_thr.value
  end

  if status.success?
    return true, stdout_str
  else
    return false, stderr_str
  end
end

def runTests
  
  yarn_or_npm = File.file?("#{$repo_path}/yarn.lock") ? "yarn" : "npm"
  
  report_command = $npm_params.nil? ? "jest --coverage --coverageDirectory='coverage' --coverageReporters='lcov'" : $npm_params
    
  run_command("cd #{$repo_path} && #{yarn_or_npm} #{report_command}")
  run_command("cp #{$repo_path}/test-reports/*-report.xml #{$output_path}")
  run_command("cp -r #{$repo_path}/coverage #{$output_path}")
      

  File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
    f.puts "AC_TEST_RESULT_PATH=#{$output_path}"
  end

  File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
    f.puts "AC_COVERAGE_RESULT_PATH=#{$output_path}/coverage"
  end

  "Tests completed successfully"
end

runTests()