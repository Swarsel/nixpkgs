{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  mandoc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "owamp";
  version = "4.4.6";

  src = fetchFromGitHub {
    owner = "perfsonar";
    repo = "owamp";
    tag = "v${finalAttrs.version}";
    sha256 = "5o85XSn84nOvNjIzlaZ2R6/TSHpKbWLXTO0FmqWsNMU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoconf
    automake
  ];

  buildInputs = [ mandoc ];

  preConfigure = ''
    I2util/bootstrap.sh
    ./bootstrap
  '';

  meta = {
    description = "Tool for performing one-way active measurements";
    homepage = "http://software.internet2.edu/owamp/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.teto ];
    platforms = lib.platforms.linux;
  };
})
