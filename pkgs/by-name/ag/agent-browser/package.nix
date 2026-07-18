{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  geist-font,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  which,
  writableTmpDirAsHomeHook,
}:

let
  pnpm = pnpm_10;

  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    tag = "v${version}";
    hash = "sha256-c+AJAXMX88t+zzFsEAtFJDjDY5EbhmEyMRGFL4t63nE=";
  };

  # The Rust CLI embeds the dashboard UI via RustEmbed at compile time.
  # Build the Next.js static export so it can be placed at the expected path.
  dashboard = stdenv.mkDerivation {
    inherit version src;
    pname = "agent-browser-dashboard";

    # Replace Google Fonts fetch with a local font from nixpkgs since the
    # Nix sandbox has no network access.
    postPatch = ''
      substituteInPlace packages/dashboard/src/app/layout.tsx --replace-fail \
        '{ Geist } from "next/font/google"' \
        'localFont from "next/font/local"'

      substituteInPlace packages/dashboard/src/app/layout.tsx --replace-fail \
        'Geist({ subsets: ["latin"], variable: "--font-sans" })' \
        'localFont({ src: "./Geist-Regular.otf", variable: "--font-sans" })'

      cp "${geist-font}/share/fonts/opentype/Geist-Regular.otf" \
        packages/dashboard/src/app/Geist-Regular.otf
    '';

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
    ];

    buildPhase = ''
      runHook preBuild
      pnpm --filter dashboard build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r packages/dashboard/out $out
      runHook postInstall
    '';

    __darwinAllowLocalNetworking = true;

    pnpmDeps = fetchPnpmDeps {
      inherit version src pnpm;
      pname = "agent-browser-dashboard";
      fetcherVersion = 3;
      hash = "sha256-ldxmXpejqVN/xuWcdLYMwNPc1VZ1rdNwRrumy8Is3N4=";
      pnpmWorkspaces = [ "dashboard" ];
    };

    pnpmWorkspaces = [ "dashboard" ];
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit version src;
  pname = "agent-browser";

  # `which_exists` spawns the external `which` binary at runtime to probe
  # for optional tools; pin it to an absolute store path.
  postPatch = ''
    substituteInPlace src/doctor/helpers.rs src/install.rs --replace-fail \
      '"which"' '"${lib.getExe which}"'
  '';

  cargoHash = "sha256-2u7yokHCxIVq16370Mg+n5kf03yUDYJmctFxN1fnaAA=";

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  # The `skills` subcommand looks for `skills/` and `skill-data/` next to
  # `bin/`, relative to the canonical exe path. See cli/src/skills.rs.
  postInstall = ''
    cp -r ../skills $out/skills
    cp -r ../skill-data $out/skill-data
  '';

  __darwinAllowLocalNetworking = true;

  # Place the pre-built dashboard where RustEmbed expects it
  postUnpack = ''
    chmod u+w source/packages/dashboard
    cp -r ${dashboard} source/packages/dashboard/out
  '';

  sourceRoot = "${finalAttrs.src.name}/cli";

  passthru = {
    inherit dashboard;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "dashboard"
      ];
    };
  };

  meta = {
    description = "Headless browser automation CLI for AI agents";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ codgician ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "agent-browser";
  };
})
