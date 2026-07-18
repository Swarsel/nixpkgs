{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libpcap,
  pkgconfig,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pcapy-ng";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "stamparm";
    repo = "pcapy-ng";
    rev = version;
    hash = "sha256-6LA2n7Kv0MiZcqUJpi0lDN4Q+GcOttYw7hJwVqK/DU0=";
  };

  nativeBuildInputs = [
    cython
    pkgconfig
  ];

  buildInputs = [ libpcap ];
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd tests
  '';

  enabledTestPaths = [ "pcapytests.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "pcapy" ];

  meta = {
    description = "Module to interface with the libpcap packet capture library";
    homepage = "https://github.com/stamparm/pcapy-ng/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
