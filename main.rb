require 'find'
require 'json'
require 'open3'

def env_has_key(key)
    return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

$output_path = env_has_key("AC_OUTPUT_DIR")
$repo_path = env_has_key("AC_REPOSITORY_DIR") || abort("Missing AC_WORKING_DIR.")
$npm_params = env_has_key("AC_NPM_COMMAND_ARGS") || "install"
$test_result_path = "#{$output_path}/test.json"

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

    run_command("brew install applesimutils")


end

yarn_or_npm = "npm"
if File.file?("#{repo_path}/yarn.lock")
    yarn_or_npm = "yarn"
end

run_command("cd #{repo_path} && #{yarn_or_npm} #{npm_params}")
runTests()
