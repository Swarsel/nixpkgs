{
  lib,
  stdenv,
  asciidoc,
  fetchFromBitbucket,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cc1541";
  version = "4.2";

  src = fetchFromBitbucket {
    owner = "ptv_claus";
    repo = "cc1541";
    rev = finalAttrs.version;
    hash = "sha256-+9ri3fUmxLHXxq9vNMjeNXfHula3PZpjewHO6z7pIhc=";
  };

  nativeBuildInputs = [ asciidoc ];
  makeFlags = [ "prefix=$(out)" ];
  # Manual generation broke in 4.2
  env.ENABLE_MAN = false;

  checkPhase = ''
    runHook preCheck

    make test

    runHook postCheck
  '';

  doInstallCheck = true;

  meta = {
    description = "Tool for creating Commodore 1541 Floppy disk images in D64, D71 or D81 format";
    homepage = "https://bitbucket.org/ptv_claus/cc1541/src/master/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.all;
    mainProgram = "cc1541";
  };
})
