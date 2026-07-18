{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pygtail";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "bgreenlee";
    repo = "pygtail";
    rev = version;
    hash = "sha256-TlXTlxeGDd+elGpMjxcJCmRuJmp5k9xj6MrViRzcST4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pygtail" ];

  meta = {
    description = "Library for reading log file lines that have not been read";
    homepage = "https://github.com/bgreenlee/pygtail";
    license = lib.licenses.gpl2Plus;
    mainProgram = "pygtail";
  };
}
