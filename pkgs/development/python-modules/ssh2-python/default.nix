{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libssh2,
  openssl,
  setuptools,
  zlib,
}:

buildPythonPackage rec {
  pname = "ssh2-python";
  version = "1.2.0.post1";

  src = fetchFromGitHub {
    owner = "ParallelSSH";
    repo = "ssh2-python";
    tag = version;
    hash = "sha256-GhkVie+UPjM1C1Jb3/ef59kuJRYmIkauTCaoksqu1LM=";
  };

  nativeBuildInputs = [
    cython
  ];

  buildInputs = [
    openssl
    zlib
    libssh2
  ];

  env = {
    SYSTEM_LIBSSH2 = true;
  };

  build-system = [ setuptools ];
  format = "setuptools";
  pythonImportsCheck = [ "ssh2" ];

  meta = {
    description = "Python bindings for libssh2 C library";
    homepage = "https://github.com/ParallelSSH/ssh2-python";
    changelog = "https://github.com/ParallelSSH/ssh2-python/blob/${src.tag}/Changelog.rst";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ infinidoge ];
  };
}
