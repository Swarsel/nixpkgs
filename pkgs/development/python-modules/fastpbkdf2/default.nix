{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  openssl,
  pytest,
  six,
}:

buildPythonPackage rec {
  pname = "fastpbkdf2";
  version = "0.2";

  # Fetching from GitHub as tests are missing in PyPI
  src = fetchFromGitHub {
    owner = "Ayrx";
    repo = "python-fastpbkdf2";
    rev = "v${version}";
    sha256 = "1hvvlk3j28i6nswb6gy3mq7278nq0mgfnpxh1rv6jvi7xhd7qmlc";
  };

  buildInputs = [ openssl ];

  propagatedBuildInputs = [
    cffi
    six
  ];

  nativeCheckInputs = [ pytest ];
  format = "setuptools";
  propagatedNativeBuildInputs = [ cffi ];

  meta = {
    description = "Python bindings for fastpbkdf2";
    homepage = "https://github.com/Ayrx/python-fastpbkdf2";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jqueiroz ];
  };
}
