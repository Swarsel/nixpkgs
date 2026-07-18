{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mo";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = "tests-always-included";
    repo = "mo";
    rev = finalAttrs.version;
    hash = "sha256-CFAvTpziKzSkdomvCf8PPXYbYcJxjB4EValz2RdD2b0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp mo $out/bin/.

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Moustache templates for Bash";
    homepage = "https://github.com/tests-always-included/mo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sheepforce ];
    mainProgram = "mo";
  };
})
