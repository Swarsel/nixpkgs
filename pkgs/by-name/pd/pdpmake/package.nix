{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pdpmake";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "rmyorston";
    repo = "pdpmake";
    rev = finalAttrs.version;
    hash = "sha256-ivRXZxm9RAWSmNfiV7BhVzVFsBKuMMpKjub8ADinYyc=";
  };

  makeFlags = [ "PREFIX=$(out)" ];
  doCheck = true;
  checkTarget = "test";
  enableParallelBuilding = true;

  meta = {
    description = "Public domain POSIX make";
    homepage = "https://github.com/rmyorston/pdpmake";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ eownerdead ];
    platforms = lib.platforms.all;
    badPlatforms = lib.platforms.darwin; # Requires `uimensat`
    mainProgram = "pdpmake";
  };
})
