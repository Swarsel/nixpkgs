{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libssh,
  openssl,
  setuptools,
  zlib,
}:

buildPythonPackage rec {
  pname = "ssh-python";
  version = "1.2.0.post1";

  src = fetchFromGitHub {
    owner = "ParallelSSH";
    repo = "ssh-python";
    tag = version;
    hash = "sha256-ix6UzyC/mFDVOvfJujwppijmsTrwNtuDAkmikrKKc2o=";
  };

  nativeBuildInputs = [ cython ];

  buildInputs = [
    openssl
    zlib
    libssh
  ];

  env = {
    SYSTEM_LIBSSH = true;
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ssh" ];

  meta = {
    description = "Python bindings for libssh C library";
    homepage = "https://github.com/ParallelSSH/ssh-python";
    changelog = "https://github.com/ParallelSSH/ssh-python/blob/${src.tag}/Changelog.rst";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ infinidoge ];
  };
}
