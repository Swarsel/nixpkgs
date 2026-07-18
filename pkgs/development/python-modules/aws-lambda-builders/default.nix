{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  parameterized,
  pip,
  pyelftools,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "aws-lambda-builders";
  version = "1.61.0";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "aws-lambda-builders";
    tag = "v${version}";
    hash = "sha256-NdVZrc6996dlV0jSWuZH/dLQdJnXO+BQb8hk3G0oXmw=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "version=read_version()," 'version="${version}",'
  '';

  nativeCheckInputs = [
    mock
    parameterized
    pip
    pyelftools
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ six ];

  disabledTestPaths = [
    # Dotnet binary needed
    "tests/integration/workflows/dotnet_clipackage/test_dotnet.py"
  ];

  disabledTests = [
    # CLI don't work in the sandbox
    "test_run_hello_workflow"
    # Don't tests integrations
    "TestCustomMakeWorkflow"
    "TestDotnet31"
    "TestDotnet6"
    "TestGoWorkflow"
    "TestJavaGradle"
    "TestJavaMaven"
    "TestNodejsNpmWorkflow"
    "TestNodejsNpmWorkflowWithEsbuild"
    "TestPipRunner"
    "TestPythonPipWorkflow"
    "TestRubyWorkflow"
    "TestRustCargo"
    "test_with_mocks"
    # Tests which are passing locally but not on Hydra
    "test_copy_dependencies_action_1_multiple_files"
    "test_move_dependencies_action_1_multiple_files"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aws_lambda_builders" ];

  meta = {
    description = "Tool to compile, build and package AWS Lambda functions";

    longDescription = ''
      Lambda Builders is a Python library to compile, build and package
      AWS Lambda functions for several runtimes & frameworks.
    '';

    homepage = "https://github.com/awslabs/aws-lambda-builders";
    changelog = "https://github.com/aws/aws-lambda-builders/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dhkl ];
    mainProgram = "lambda-builders";
  };
}
