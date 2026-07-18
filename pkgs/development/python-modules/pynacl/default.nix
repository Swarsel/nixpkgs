{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  hypothesis,
  libsodium,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "pynacl";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "pyca";
    repo = "pynacl";
    tag = version;
    hash = "sha256-EzzJVRDgYQO6T8YIQjad/Eb9O+BXT4IpOpa48fpBPnc=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ sphinxHook ];
  buildInputs = [ libsodium ];
  env.SODIUM_INSTALL = "system";

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytest-xdist
  ];

  build-system = [
    cffi
    setuptools
  ];

  # cffi is listed in both build-system.requires and project.dependencies,
  # and is indeed needed in both when cross-compiling
  dependencies = [ cffi ];
  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "nacl" ];

  meta = {
    description = "Python binding to the Networking and Cryptography (NaCl) library";
    homepage = "https://github.com/pyca/pynacl/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
  };
}
