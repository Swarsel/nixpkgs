{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "semver-tool";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "fsaintjacques";
    repo = "semver-tool";
    rev = finalAttrs.version;
    sha256 = "sha256-BnHuiCxE0VjzMWFTEMunQ9mkebQKIKbbMxZVfBUO57Y=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install src/semver $out/bin

    runHook postInstall
  '';

  dontBuild = true; # otherwise we try to 'make' which fails.

  meta = {
    description = "Semver bash implementation";
    homepage = "https://github.com/fsaintjacques/semver-tool";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.qyliss ];
    platforms = lib.platforms.unix;
    mainProgram = "semver";
  };
})
