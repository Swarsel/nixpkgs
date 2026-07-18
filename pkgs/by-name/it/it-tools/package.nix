{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "it-tools";
  version = "0-unstable-2026-02-12";

  src = fetchFromGitHub {
    owner = "CorentinTh";
    repo = "it-tools";
    rev = "d505845f918e946ec300af7b36efc107e2f66e9e";
    hash = "sha256-dWVRiLbJ1X4yHT5yRcq+KaHmjjtc24yQg0jQvWTPNwU=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_11
  ];

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -R ./dist/* $out/lib/

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    fetcherVersion = 4;
    hash = "sha256-ju8YO0IHIGJtCi5TnxvfLUXcTqKWnTBKAGFBhzQJTok=";
    pnpm = pnpm_11;
  };

  meta = {
    description = "Self-hostable website containing handy tools for developers, with great UX";
    homepage = "https://it-tools.tech/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ akotro ];
  };
})
