{
  lib,
  aws-encryption-sdk-cli,
  fetchPypi,
  nix-update-script,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "aws-encryption-sdk-cli";
  version = "4.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-FfLgR7gocZ0cLV7bxqvKNI+Fs7kQF0XhR3zf6tHXwOE=";
    pname = "aws_encryption_sdk_cli";
  };

  doCheck = true;

  nativeCheckInputs = with python3Packages; [
    mock
    pytest-mock
    pytest7CheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    attrs
    aws-encryption-sdk
    base64io
    setuptools # for pkg_resources
    urllib3
  ];

  disabledTestPaths = [
    # requires networking
    "test/integration"
  ];

  pyproject = true;

  # Upstream did not adapt to pytest 8 yet.
  pytestFlags = [
    "-Wignore::pytest.PytestRemovedIn8Warning"
  ];

  pythonRelaxDeps = [ "aws-encryption-sdk" ];

  passthru = {
    tests.version = testers.testVersion {
      command = "aws-encryption-cli --version";
      package = aws-encryption-sdk-cli;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI wrapper around aws-encryption-sdk-python";
    homepage = "https://aws-encryption-sdk-cli.readthedocs.io/";
    changelog = "https://github.com/aws/aws-encryption-sdk-cli/blob/v${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    mainProgram = "aws-encryption-cli";
  };
})
