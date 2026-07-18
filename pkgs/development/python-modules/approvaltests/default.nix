{
  lib,
  fetchFromGitHub,
  allpairspy,
  approval-utilities,
  beautifulsoup4,
  buildPythonPackage,
  empty-files,
  mock,
  numpy,
  pyperclip,
  pytest,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  setuptools,
  testfixtures,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "approvaltests";
  version = "18.0.1";

  src = fetchFromGitHub {
    owner = "approvals";
    repo = "ApprovalTests.Python";
    tag = "v${version}";
    hash = "sha256-2lz3TMI4/QoNVfnZga5Ro9rheixFpVJfNbvVLy0lnLA=";
  };

  postPatch = ''
    test -f setup.py || mv setup/setup.approvaltests.py setup.py

    patchShebangs internal_documentation/scripts
  '';

  nativeCheckInputs = [
    numpy
    pytest-asyncio
    pytestCheckHook
    pyyaml
  ];

  build-system = [ setuptools ];

  dependencies = [
    allpairspy
    approval-utilities
    beautifulsoup4
    empty-files
    mock
    pyperclip
    pytest
    testfixtures
    typing-extensions
  ];

  disabledTests = [
    "test_warnings"
    # test runs another python interpreter, ignoring $PYTHONPATH
    "test_command_line_verify"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "approvaltests.approvals"
    "approvaltests.reporters.generic_diff_reporter_factory"
  ];

  meta = {
    description = "Assertion/verification library to aid testing";
    homepage = "https://github.com/approvals/ApprovalTests.Python";
    changelog = "https://github.com/approvals/ApprovalTests.Python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
