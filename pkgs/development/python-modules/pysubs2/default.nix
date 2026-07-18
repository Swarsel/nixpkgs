{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysubs2";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "tkarabela";
    repo = "pysubs2";
    rev = version;
    hash = "sha256-fKSb7MfBHGft8Tp6excjfkVXKnHRER11X0QxbR1zD4I=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "pysubs2" ];

  meta = {
    description = "Python library for editing subtitle files";
    homepage = "https://github.com/tkarabela/pysubs2";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pysubs2";
  };
}
