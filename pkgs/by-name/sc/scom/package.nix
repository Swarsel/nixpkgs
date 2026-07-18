{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "scom";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "crash-systems";
    repo = "scom";
    tag = finalAttrs.version;
    hash = "sha256-eFnCXMrks5V6o+0+vMjR8zaCdkc+hC3trSS+pOh4Y6U=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  enableParallelBuilding = true;

  meta = {
    description = "Minimal serial communication tool";
    homepage = "https://github.com/crash-systems/scom";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ savalet ];
    platforms = lib.platforms.unix;
    mainProgram = "scom";
  };
})
