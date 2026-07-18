{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  iperf3,
  setuptools,
}:

buildPythonPackage rec {
  pname = "iperf3";
  version = "0.1.11";

  src = fetchFromGitHub {
    owner = "thiezn";
    repo = "iperf3-python";
    tag = "v${version}";
    hash = "sha256-kcEgG9lkYUqFtTgrGZdEQ0AHsx3yQIMFOG4A7d4mAnE=";
  };

  # Tests require iperf3 client and server setup
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "iperf3" ];

  meta = {
    description = "Python wrapper around iperf3";
    homepage = "https://github.com/thiezn/iperf3-python";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
