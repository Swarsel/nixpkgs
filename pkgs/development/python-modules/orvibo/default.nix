{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "orvibo";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "happyleavesaoc";
    repo = "python-orvibo";
    rev = version;
    sha256 = "sha256-Azmho47CEbRo18emmLKhYa/sViQX0oxUTUk4zdrpOaE=";
  };

  # Project as no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "orvibo" ];

  meta = {
    description = "Python client to work with Orvibo devices";
    homepage = "https://github.com/happyleavesaoc/python-orvibo";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
