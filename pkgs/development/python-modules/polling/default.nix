{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "polling";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "justiniso";
    repo = "polling";
    rev = "v${version}";
    hash = "sha256-Qy2QxCWzAjZMJ6yxZiDT/80I2+rLimoG8/SYxq960Tk=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "polling" ];

  meta = {
    description = "Powerful polling utility in Python";
    homepage = "https://github.com/justiniso/polling";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
