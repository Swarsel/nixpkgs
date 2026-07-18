{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "duet";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "google";
    repo = "duet";
    tag = "v${version}";
    hash = "sha256-P7JxUigD7ZyhtocV+YuAVxuUYVa4F7PpXuA1CCmcMvg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];

  disabledTests = [
    # test fails because builder is too busy and cannot finish quickly enough
    "test_repeated_sleep"
  ];

  pyproject = true;
  pythonImportsCheck = [ "duet" ];

  meta = {
    description = "Simple future-based async library for python";
    homepage = "https://github.com/google/duet";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
