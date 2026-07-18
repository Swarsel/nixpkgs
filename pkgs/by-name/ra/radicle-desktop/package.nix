{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  clippy,
  fetchFromRadicle,
  fetchNpmDeps,
  git,
  glib,
  gtk3,
  libsoup_3,
  nodejs,
  npmHooks,
  openssh,
  openssl,
  pkg-config,
  playwright-driver,
  radicle-node,
  rustPlatform,
  rustfmt,
  webkitgtk_4_1,
  wrapGAppsHook4,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "radicle-desktop";
  version = "0.13.0";

  src = fetchFromRadicle {
    repo = "z4D5UCArafTzTQpDZNQRuqswh3ury";
    tag = "releases/${finalAttrs.version}";
    hash = "sha256-XpzOzyUwAGLF/klXXbBFX5oLRSURB+AsL8n9WWv5x7s=";
    leaveDotGit = true;

    postFetch = ''
      git -C $out rev-parse --short HEAD > $out/.git_head
      rm -rf $out/.git
    '';

    seed = "seed.radicle.dev";
  };

  postPatch = ''
    patchShebangs scripts/copy-katex-assets scripts/check-js scripts/check-rs

    mkdir -p public/twemoji
    cp -t public/twemoji -r -- ${finalAttrs.twemojiAssets}/assets/svg/*
    : >scripts/install-twemoji-assets

    substituteInPlace scripts/check-rs \
      --replace-fail "-Dwarnings" ""
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    npmHooks.npmConfigHook
    nodejs
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk3
    libsoup_3
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ webkitgtk_4_1 ];

  cargoHash = "sha256-HInTwQYuLVFnRCbQq2hNRPGJP1I9gBRQZQ9ul3DWtBQ=";

  env = {
    HW_RELEASE = "nixpkgs";
    PLAYWRIGHT_BROWSERS_PATH = playwright-driver.browsers;
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = true;
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
  };

  preBuild = ''
    export GIT_HEAD=$(<$src/.git_head)
  '';

  nativeCheckInputs = [
    git
    openssh
    radicle-node
    rustfmt
    clippy
    writableTmpDirAsHomeHook
  ];

  checkPhase = ''
    runHook preCheck

    export RAD_PASSPHRASE=""
    rad auth --alias test
    bins="tests/tmp/bin/heartwood/$HW_RELEASE"
    mkdir -p "$bins"
    cp -t "$bins" -- ${radicle-node}/bin/*
    echo -n "$HW_RELEASE" >tests/support/heartwood-release

    npm run build:http
    npm run test:unit
    scripts/check-js
    scripts/check-rs

    runHook postCheck
  '';

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-EigvRDUmiuz/wt5vZ3NSxovxjvxHVGrHdA9HIod/fO8=";
  };

  twemojiAssets = fetchFromGitHub {
    hash = "sha256-YoOnZ5uVukzi/6bLi22Y8U5TpplPzB7ji42l+/ys5xI=";
    owner = "twitter";
    repo = "twemoji";
    tag = "v14.0.2";
  };

  passthru = {
    inherit (finalAttrs) env;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Radicle desktop app";
    homepage = "https://radicle.network/nodes/seed.radicle.dev/rad:z4D5UCArafTzTQpDZNQRuqswh3ury";
    changelog = "https://radicle.network/nodes/seed.radicle.dev/rad:z4D5UCArafTzTQpDZNQRuqswh3ury/tree/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ faukah ];
    platforms = lib.platforms.unix;
    mainProgram = "radicle-desktop";
    teams = [ lib.teams.radicle ];
  };
})
