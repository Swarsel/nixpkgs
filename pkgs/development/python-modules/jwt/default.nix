{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  freezegun,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jwt";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "GehirnInc";
    repo = "python-jwt";
    tag = "v${version}";
    hash = "sha256-Cv64SmhkETm8mx1Kj5u0WZpCPjPNvC+KS6/XaMzxCho=";
  };

  postPatch = ''
    # pytest-flake8 is incompatible flake8 6.0.0 and currently unmaintained
    substituteInPlace setup.cfg --replace "--flake8" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    freezegun
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "jwt" ];

  meta = {
    description = "JSON Web Token library for Python 3";
    homepage = "https://github.com/GehirnInc/python-jwt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thornycrackers ];
  };
}
