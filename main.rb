require 'find'
require 'json'
require 'open3'

def env_has_key(key)
    return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

$output_path = env_has_key("AC_OUTPUT_DIR") || abort("Missing AC_OUTPUT_DIR.")
$repo_path = env_has_key("AC_REPOSITORY_DIR") || abort("Missing AC_REPOSITORY_DIR.")
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
  
    # Return success status and error message (if any)
    if status.success?
      return true, stdout_str
    else
      return false, stderr_str
    end
end

def runTests
    results = []
  
    begin
      yarn_or_npm = File.file?("#{$repo_path}/yarn.lock") ? "yarn" : "npm"
  
      report_command = $npm_params.nil? ? "jest --coverage --coverageDirectory='coverage' --coverageReporters='lcov'" : $npm_params
      
      # Run commands and store the results
      results << run_command("cd #{$repo_path} && #{yarn_or_npm} #{report_command}")
      results << run_command("cp #{$repo_path}/test-reports/*-report.xml #{$output_path}")
      results << run_command("cp -r #{$repo_path}/coverage #{$output_path}")
      
      # Write AC_TEST_RESULT_PATH reserved variable to the ENV file for test report component
      File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
        f.puts "AC_TEST_RESULT_PATH=#{$output_path}"
      end
      
      # Write AC_COVERAGE_RESULT_PATH reserved variable (coverage path) to the ENV file for test report component
      File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
        f.puts "AC_COVERAGE_RESULT_PATH=#{$output_path}/coverage"
      end
  
    rescue => e
      # Catch and return any unexpected error
      return "Error occurred: #{e}"
    end
  
    # Check results and handle failure
    results.each_with_index do |(success, result), index|
      unless success
        abort("Command #{index + 1} failed: #{result}")
      end
    end
  
    "Tests completed successfully"
end


runTests()