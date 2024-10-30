require 'open3'

def env_has_key(key)
	return (ENV[key] != nil && ENV[key] !="") ? ENV[key] : abort("Missing #{key}.")
end

$output_path = env_has_key("AC_OUTPUT_DIR")
$repo_path = env_has_key("AC_REPOSITORY_DIR")
$npm_params = (ENV["AC_RN_TEST_COMMAND_ARGS"] != nil && ENV["AC_RN_TEST_COMMAND_ARGS"] !="") ? ENV["AC_RN_TEST_COMMAND_ARGS"] : nil

def run_command(command)
  puts "@@[command] #{command}"
  stdout_str, stderr_str, status = Open3.capture3(command)

  if status.success?
    puts stdout_str unless stdout_str.empty?
    puts stderr_str unless stderr_str.empty?
    return stderr_str.empty? ? stdout_str : stderr_str
  else
    return stderr_str
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