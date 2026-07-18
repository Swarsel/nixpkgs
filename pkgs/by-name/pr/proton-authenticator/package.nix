{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  glib-networking,
  libsoup_3,
  nodejs_24,
  pkg-config,
  python3,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
  yarn-berry_4,
}:

let
  pname = "proton-authenticator";
  version = "1.1.6";
  nodejs = nodejs_24;
  yarn-berry = yarn-berry_4.override { inherit nodejs; };

  src = fetchFromGitHub {
    owner = "ProtonMail";
    repo = "WebClients";
    rev = "proton-authenticator@${version}";
    hash = "sha256-Zd3cSkzRBDnLNY2sM7EXWCX6F6+ePOpslnEroludzag=";
  };

in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit pname version src;

  patches = [
    # It disables scripts (not needed for proton-authenticator workspace).
    ./disable-scripts.patch
    ./package.json.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    yarn-berry
    yarn-berry.yarnBerryConfigHook
    wrapGAppsHook4
    pkg-config
    (python3.withPackages (ps: [ ps.setuptools ]))
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libsoup_3
    webkitgtk_4_1
  ];

  cargoHash = "sha256-bkjjwwSizj/ltY3ISPKEL6rvg37RaDf/Ou7a7jYS47I=";
  __structuredAttrs = true;
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "applications/authenticator/src-tauri";
  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes yarnLock;
    hash = "sha256-FiDuAwEj/AIH/lJRLyuNPvthcoynsFGcUYZyx7DMnFA=";
  };

  postUnpack = ''
    cp --no-preserve=all ${./yarn.lock} $sourceRoot/yarn.lock
  '';

  sourceRoot = "${src.name}";

  tauriBuildFlags = [
    "--no-sign"
  ];

  # The original yarn.lock contains references to private registries.
  # How to generate a new yarn.lock:
  # 1. Delete the original yarn.lock.
  # 2. Apply the patch `package.json.patch`.
  # 3. Run `export SENTRYCLI_SKIP_DOWNLOAD=1`, `yarn workspaces focus proton-authenticator --production` and then `yarn install` into the repository directory.
  # 4. Generate a new `missing-hashes.json` file by running `nix run nixpkgs#yarn-berry_4.yarn-berry-fetcher -- missing-hashes yarn.lock > missing-hashes.json`.
  # 5. Move the generated `yarn.lock` and `missing-hashes.json` files into this directory.
  yarnLock = ./yarn.lock;

  meta = {
    description = "Two-factor authentication manager with optional sync (built from source)";

    longDescription = ''
      This package builds proton-authenticator from source.

      Changed: proton-authenticator is now source-compiled by default.
      For the pre-built binary version, use proton-authenticator-bin instead.
    '';

    homepage = "https://proton.me/authenticator";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      demic-dev
      pbek
    ];

    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "proton-authenticator";
  };
})
