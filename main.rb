require 'find'
require 'json'
require 'open3'

def env_has_key(key)
    return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

$output_path = env_has_key("AC_OUTPUT_DIR") || abort("Missing AC_OUTPUT_DIR.")
$repo_path = env_has_key("AC_REPOSITORY_DIR") || abort("Missing AC_REPOSITORY_DIR.")
$npm_params = env_has_key("AC_RN_TEST_COMMAND_ARGS") || "jest"
$test_result_path = "#{$output_path}/test.json"

puts "REPO DIR #{env_has_key("AC_REPOSITORY_DIR")}"

def run_command(command)
    puts "@@[command] #{command}"
    status = nil
    stdout_str = nil
    stderr_str = nil
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdout.each_line do |line|
            puts line
        end
        stdout_str = stdout.read
        stderr_str = stderr.read
        status = wait_thr.value
    end
  
    unless status.success?
        abort(stderr_str)
    end
end

puts "Repo Path #{$repo_path}"
run_command("ls -la")

$yarn_or_npm = "npm"
if File.file?("#{$repo_path}/yarn.lock")
    yarn_or_npm = "yarn"
end

def runTests
    run_command("cd #{$repo_path} && ls -la") # add additional params from user
    yarn_or_npm = "npm"
    if File.file?("#{$repo_path}/yarn.lock")
        yarn_or_npm = "yarn"
    end

    run_command("cd #{$repo_path} && yarn jest --reporters=default --reporters=jest-junit --coverage --coverageDirectory='coverage' --coverageReporters='json' --coverageReporters='lcov' && ls -la")

    File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
        f.puts "AC_TEST_RESULT_PATH=#{$output_path}/junit.xml"
    end
    
    File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
        f.puts "AC_COVERAGE_RESULT_PATH=#{$output_path}/coverage"
    end
    
end


runTests()