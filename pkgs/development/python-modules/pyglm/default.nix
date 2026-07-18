{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyglm";
  version = "2.8.3";

  src = fetchFromGitHub {
    owner = "Zuzu-Typ";
    repo = "PyGLM";
    tag = version;
    hash = "sha256-7IN/kqFCwAMeVUrBB/CfCm9bSt1dHMbbLtqVInRFCk0=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # Having the source root in `sys.path` causes import issues
  preCheck = ''
    cd test
  '';

  build-system = [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "pyglm"
    "glm"
  ];

  meta = {
    description = "OpenGL Mathematics (GLM) library for Python written in C++";
    homepage = "https://github.com/Zuzu-Typ/PyGLM";
    changelog = "https://github.com/Zuzu-Typ/PyGLM/releases/tag/${src.tag}";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ sund3RRR ];
  };
}
