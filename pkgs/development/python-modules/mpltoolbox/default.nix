{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ipympl,
  # tests
  matplotlib,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "mpltoolbox";
  version = "26.2.0";

  src = fetchFromGitHub {
    owner = "scipp";
    repo = "mpltoolbox";
    tag = version;
    hash = "sha256-vEnuTE+YZ8gK+desT4Bt5kqa2TSD0UkSSHKr7Kt8Xlo=";
  };

  nativeCheckInputs = [
    ipympl
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    matplotlib
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mpltoolbox"
  ];

  meta = {
    description = "Interactive tools for Matplotlib";
    homepage = "https://scipp.github.io/mpltoolbox/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
