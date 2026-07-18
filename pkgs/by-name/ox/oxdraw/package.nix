{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  geist-font,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (
  finalAttrs:
  let
    # We manually build the frontend because otherwise it'll try to download stuff from within the sandbox and fail
    frontend = buildNpmPackage {
      inherit (finalAttrs) version src;
      pname = "oxdraw-frontend";

      patches = [
        # By default, NextJS tries to fetch fonts from google
        # Because of sandboxing, that fails, so we use the
        # font from nixpkgs
        ./font-lookup.patch
      ];

      npmDepsHash = "sha256-Yyox/x78spQqCJDJkPVuzfeAbtd/fdyihDHudIqruo4=";

      buildPhase = ''
        runHook preBuild
        cp ${geist-font}/share/fonts/opentype/Geist{,Mono}-Regular.otf .
        npm run build
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        cp -r out $out
        runHook postInstall
      '';

      sourceRoot = "source/frontend";
    };
  in
  {
    pname = "oxdraw";
    version = "0.2.0";

    src = fetchFromGitHub {
      owner = "RohanAdwankar";
      repo = "oxdraw";
      tag = "v${finalAttrs.version}";
      hash = "sha256-2B0G5aWRtUvZiCsX1fOw6M2UhShZaDj11r/fXCemGVc=";
    };

    strictDeps = true;
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ openssl ];
    cargoHash = "sha256-YedNESkXKbfl7FWea7VpDR+59b9WLtZ7GNcyJ7D9yPg=";
    env.OXDRAW_BUNDLED_WEB_DIST = frontend;

    preBuild = ''
      # The build.rs builds the frontend, which we manually build via Nix already
      rm build.rs
    '';

    __structuredAttrs = true;
    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Diagram as Code Tool Written in Rust with Draggable Editing";
      homepage = "https://github.com/RohanAdwankar/oxdraw";
      changelog = "https://github.com/RohanAdwankar/oxdraw/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.kilyanni ];
      platforms = lib.platforms.linux;
      mainProgram = "oxdraw";
    };
  }
)
