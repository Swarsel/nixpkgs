{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  callPackage,
  nix-update-script,
  pkg-config,
  rustPlatform,
  testers,
  xz,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tauri";
  version = "2.11.4";

  src = fetchFromGitHub {
    owner = "tauri-apps";
    repo = "tauri";
    tag = "tauri-cli-v${finalAttrs.version}";
    hash = "sha256-bYkooyO8msGlewK4zU8NSgGQwAKzc5xfboMakugukBc=";
  };

  patches = [
    ./skip-icon-macos.patch
  ];

  # Explicitly enable optional `rustls` dependency.
  postPatch = ''
    substituteInPlace crates/tauri/Cargo.toml \
      --replace-fail 'dep:rustls' 'rustls'
  '';

  nativeBuildInputs = lib.optionals (stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isLinux) [
    pkg-config
  ];

  buildInputs =
    # Required for tauri-macos-sign and RPM support in tauri-bundler
    lib.optionals (stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isLinux) [
      bzip2
      xz
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      zstd
    ];

  cargoHash = "sha256-S1t4GsBQ4/ktSvLitb8FufnXwZfwVc9r8z9tCLRDy8Y=";

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  cargoBuildFlags = [
    "--package"
    "tauri-cli"
  ];

  cargoTestFlags = finalAttrs.cargoBuildFlags;

  passthru = {
    gst-plugin = callPackage ./gst-plugin.nix { };
    # See ./doc/hooks/tauri.section.md
    hook = callPackage ./hook.nix { cargo-tauri = finalAttrs.finalPackage; };

    tests = {
      version = testers.testVersion { package = finalAttrs.finalPackage; };
      hook = callPackage ./test-app.nix { cargo-tauri = finalAttrs.finalPackage; };
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "tauri-cli-v(.*)"
      ];
    };
  };

  meta = {
    description = "Build smaller, faster, and more secure desktop applications with a web frontend";
    homepage = "https://tauri.app/";
    changelog = "https://github.com/tauri-apps/tauri/releases/tag/tauri-cli-v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      getchoo
      happysalada
    ];

    mainProgram = "cargo-tauri";
  };
})
