{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "crcpp";
  version = "1.2.1.0";

  src = fetchFromGitHub {
    owner = "d-bahr";
    repo = "CRCpp";
    rev = "release-${finalAttrs.version}";
    sha256 = "sha256-9oAG2MCeSsgA9x1mSU+xiKHUlUuPndIqQJnkrItgsAA=";
  };

  nativeBuildInputs = [ cmake ];
  doCheck = true;

  meta = {
    description = "Easy to use and fast C++ CRC library";
    homepage = "https://github.com/d-bahr/CRCpp";
    changelog = "https://github.com/d-bahr/CRCpp/releases/tag/release-${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
