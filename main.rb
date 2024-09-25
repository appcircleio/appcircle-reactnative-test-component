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

def runTests
    yarn_or_npm = "npm"
    if File.file?("#{$repo_path}/yarn.lock")
        yarn_or_npm = "yarn"
    end

    report_command = $npm_params.nil? ? "jest --reporters=default --reporters=jest-junit --coverage --coverageDirectory='coverage' --coverageReporters='json' --coverageReporters='lcov'" : $npm_params
    run_command("cd #{$repo_path} && #{yarn_or_npm} #{report_command}")
    
    # copy test results to output directory for downloadable artifacts
    run_command("cp #{$repo_path}/junit.xml #{$output_path}")
    run_command("cp -r #{$repo_path}/coverage #{$output_path}")
    

    # Write AC_TEST_RESULT_PATH reserved variable to the ENV file for test report component
    File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
        f.puts "AC_TEST_RESULT_PATH=#{$output_path}"
    end
    # Write AC_COVERAGE_RESULT_PATH reserved variable(coverage path) to the ENV file  report for test report component
    File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
        f.puts "AC_COVERAGE_RESULT_PATH=#{$output_path}/coverage"
    end
    
end


runTests()