{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
}:

rustPlatform.buildRustPackage (
  finalAttrs:
  let
    frontendPname = "wealthfolio-frontend";

    frontend = stdenv.mkDerivation {
      inherit (finalAttrs) version src;
      inherit (finalAttrs) meta;
      pname = frontendPname;
      strictDeps = true;

      nativeBuildInputs = [
        nodejs
        pnpm_10
        pnpmConfigHook
      ];

      buildPhase = ''
        export BUILD_TARGET=web
        pnpm --filter frontend... build
      '';

      installPhase = ''
        mkdir -p $out
        cp -R dist/* $out/
      '';

      __structuredAttrs = true;

      pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs) version src;
        pname = frontendPname;
        fetcherVersion = 3;
        hash = "sha256-fryLXUVzyDT1jOuS5sIf9kpCJ40oHaxFRJFKMrn7EGs=";
        pnpm = pnpm_10;
      };
    };
  in
  {
    pname = "wealthfolio-server";
    version = "3.6.2";

    src = fetchFromGitHub {
      owner = "wealthfolio";
      repo = "wealthfolio";
      tag = "v${finalAttrs.version}";
      hash = "sha256-2Chwr7OifQ5PgRAnxDEeAxyYaxVQqS32mezqzUBKKyU=";
    };

    nativeBuildInputs = [ makeWrapper ];
    cargoHash = "sha256-pfUrfIZmuibjFYzcuh57WU/pTlXFZNWYgurNYn+Wvus=";

    postInstall = ''
      mkdir -p $out/share/wealthfolio/dist

      cp -R ${frontend}/* $out/share/wealthfolio/dist/

      wrapProgram $out/bin/wealthfolio-server \
        --set WF_STATIC_DIR "$out/share/wealthfolio/dist"
    '';

    __structuredAttrs = true;
    buildAndTestSubdir = "apps/server";
    cargoRoot = ".";

    meta = {
      description = "Self-hosted web app for Wealthfolio";
      homepage = "https://wealthfolio.app/";
      changelog = "https://github.com/wealthfolio/wealthfolio/tag/${finalAttrs.src.tag}";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [ luuumine ];
      platforms = lib.platforms.linux;
      mainProgram = "wealthfolio-server";
    };
  }
)
