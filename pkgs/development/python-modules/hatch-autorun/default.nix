{
  lib,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hatch-autorun";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ofek";
    repo = "hatch-autorun";
    tag = "v${version}";
    hash = "sha256-79k3KolvmjGf8ubCQMhtOH5+OeqQrmz2Q6r0ZG98424=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    build
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    hatchling
  ];

  disabledTestPaths = [
    # requires network via invoking pip
    "tests/test_build.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "hatch_autorun"
  ];

  meta = {
    description = "Hatch build hook plugin to inject code that will automatically run";
    homepage = "https://github.com/ofek/hatch-autorun";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
