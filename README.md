# Appcircle React Native UI Test Component

Run React Native UI Tests with Detox

## Required Input Variables

- `$AC_REPOSITORY_DIR`: Specifies the cloned repository directory.
- `$AC_OUTPUT_DIR`: Specify the output directory for test results.
- `$AC_RN_TEST_COMMAND_ARGS`: Specify additional command arguments for running Jest tests, such as `--debug`. For more information, see the Jest [CLI options](https://jestjs.io/docs/cli#options).

## Output Variables

- `$AC_TEST_RESULT_PATH`: Path to the test result file.
- `$AC_COVERAGE_RESULT_PATH`: Path to the coverage result file.