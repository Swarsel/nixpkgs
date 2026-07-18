{
  lib,
  buildPythonPackage,
  fetchPypi,
  paramiko,
  robotframework,
  scp,
}:

buildPythonPackage rec {
  pname = "robotframework-sshlibrary";
  version = "3.8.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "aedf8a02bcb7344404cf8575d0ada25d6c7dc2fcb65de2113c4e07c63d2446c2";
  };

  propagatedBuildInputs = [
    robotframework
    paramiko
    scp
  ];

  # unit tests are impure
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "SSHLibrary is a Robot Framework test library for SSH and SFTP";
    homepage = "https://github.com/robotframework/SSHLibrary";
    license = lib.licenses.asl20;
  };
}
