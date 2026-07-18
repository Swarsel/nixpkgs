{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  electron,
  makeWrapper,
}:

buildNpmPackage {
  pname = "flaci";
  version = "0-unstable-2024-12-10";

  src = fetchFromGitHub {
    owner = "gitmh";
    repo = "FLACI";
    rev = "cc03bb2b4c8cf205d04936cc2110acd34397b789";
    hash = "sha256-Wgkxlz4d1KNoPL9290D1qIbOqUYW/iAIWE9YL35Tfno=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  npmDepsHash = "sha256-6X4R6D9GAe4DiIXCT62xKbHhLqdTE/BLlXJQKwt8oaQ=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/flaci}
    cp -r * $out/share/flaci/
    makeWrapper ${lib.getExe electron} $out/bin/FLACI \
      --add-flags $out/share/flaci \
      --add-flags "--no-sandbox"

    runHook postInstall
  '';

  dontNpmBuild = true;
  dontWrapGApps = true;

  meta = {
    description = "Create and test formal languages with automaton and create diagrams for them";
    homepage = "https://flaci.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ annaaurora ];
    mainProgram = "FLACI";
  };
}
