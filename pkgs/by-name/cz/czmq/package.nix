{
  lib,
  stdenv,
  fetchurl,
  zeromq,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "czmq";
  version = "4.2.1";

  src = fetchurl {
    url = "https://github.com/zeromq/czmq/releases/download/v${finalAttrs.version}/czmq-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-XXIKIEwqWGRdb3ZDrxXVY6cS2tmMnTLB7ZEzd9qmrDk=";
  };

  # Needs to be propagated for the .pc file to work
  propagatedBuildInputs = [ zeromq ];

  meta = {
    description = "High-level C Binding for ZeroMQ";
    homepage = "http://czmq.zeromq.org/";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
    mainProgram = "zmakecert";
  };
})
