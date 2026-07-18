{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage {
  pname = "contexttimer";
  version = "unstable-2024-09-05";

  src = fetchFromGitHub {
    owner = "brouberol";
    repo = "contexttimer";
    rev = "8e77927b8b75365f8e2bc456d2457b3e47c67815";
    hash = "sha256-LCyXJa+7XkfxzcLGonv1yfOW+gZhLFBAbBT+5IP39qA=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  preCheck = ''
    substituteInPlace tests/test_timer.py \
      --replace-fail "assertRegexpMatches" "assertRegex"
  '';

  build-system = [ setuptools ];
  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "contexttimer" ];

  meta = {
    description = "Timer as a context manager";
    homepage = "https://github.com/brouberol/contexttimer";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
