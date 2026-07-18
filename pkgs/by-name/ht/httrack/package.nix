{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  openssl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "httrack";
  version = "3.49.7";

  src = fetchFromGitHub {
    owner = "xroche";
    repo = "httrack";
    tag = finalAttrs.version;
    hash = "sha256-GTNXTFU5a/c1F6dBE8iHOq4PyTgUhXrjLEE6FsPeJbQ=";
    fetchSubmodules = true;
  };

  buildInputs = [
    libiconv
    openssl
    zlib
  ];

  meta = {
    description = "Easy-to-use offline browser / website mirroring utility";
    homepage = "https://www.httrack.com";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ tbutter ];
    platforms = with lib.platforms; unix;
  };
})
