{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rowan";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "glotzerlab";
    repo = "rowan";
    rev = "v${version}";
    hash = "sha256-fcxVpzLhbLjPIifNBx0olq1dUTmNM9IH38MQybkWZSg=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    numpy
  ];

  nativeCheckInputs = [
    pytestCheckHook
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "rowan" ];

  meta = {
    description = "Python package for working with quaternions";
    homepage = "https://github.com/glotzerlab/rowan";
    changelog = "https://github.com/glotzerlab/rowan/blob/${src.rev}/ChangeLog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
