{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fpattern";
  version = "1.9";

  src = fetchFromGitHub {
    owner = "Loadmaster";
    repo = "fpattern";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/QvMQCmoocaXfDm3/c3IAPyfZqR6d7IiJ9UoFKZTpVI=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/include
    cp *.c *.h $out/include
    runHook postInstall
  '';

  meta = {
    description = "Filename pattern matching library functions for DOS, Windows, and Unix";
    homepage = "https://github.com/Loadmaster/fpattern";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hughobrien ];
    platforms = with lib.platforms; linux;
  };
})
