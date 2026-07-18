{
  lib,
  fetchFromGitHub,
  # nativeBuildInputs
  cargo-bundle,
  cctools,
  clangStdenv,
  fetchgit,
  # buildInputs
  fontconfig,
  gn,
  linkFarm,
  llvmPackages,
  moltenvk,
  ninja,
  pkg-config,
  python3,
  runCommand,
  rustPlatform,
  sdl3,
  sdl3-ttf,
  # nativeInstallCheckInputs
  versionCheckHook,
  zstd,
}:
let
  stdenv = clangStdenv;
in
rustPlatform.buildRustPackage.override { inherit stdenv; } (finalAttrs: {
  pname = "gopher64";
  version = "1.1.20";

  src = fetchFromGitHub {
    owner = "gopher64";
    repo = "gopher64";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gss0ZGTptk5O67SS+r3i3Caf9I7GQxP0RlHx7GfBihw=";
    fetchSubmodules = true;
  };

  # don't use lld on aarch64-linux
  postPatch = ''
    substituteInPlace .cargo/config.toml \
      --replace-fail 'rustflags = ["-C", "link-arg=-fuse-ld=lld"]' ""
  '';

  nativeBuildInputs = [
    pkg-config
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cargo-bundle
    cctools.libtool
  ];

  buildInputs = [
    fontconfig
    sdl3
    sdl3-ttf
    zstd
  ];

  cargoHash = "sha256-rmt2b8lk/9ts8v33yguuSFcbFvUX00icg1onmhCbDTQ=";

  env = {
    GIT_DESCRIBE = finalAttrs.version;
    LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang}/lib";
    SKIA_GN_COMMAND = lib.getExe gn;
    SKIA_NINJA_COMMAND = lib.getExe ninja;

    # See pkgs/by-name/ne/neovide/package.nix
    SKIA_SOURCE_DIR =
      let
        repo = fetchFromGitHub {
          hash = "sha256-J7mBQ124/dODxX6MsuMW1NHizCMATAqdSzwxpP2afgk=";
          owner = "rust-skia";
          repo = "skia";
          # see rust-skia:skia-bindings/Cargo.toml#package.metadata skia
          tag = "m142-0.89.1";
        };
        # The externals for skia are taken from skia/DEPS
        externals = linkFarm "skia-externals" (
          lib.mapAttrsToList (name: value: {
            inherit name;
            path = fetchgit value;
          }) (lib.importJSON ./skia-externals.json)
        );
      in
      runCommand "source" { } ''
        cp -R ${repo} $out
        chmod -R +w $out
        ln -s ${externals} $out/third_party/externals
      '';

    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  # no checks
  doCheck = false;

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    # cargo-bundle expects the binary in target/release
    release_target="target/${stdenv.hostPlatform.rust.cargoShortTarget}/release"
    mv $release_target/gopher64 target/release/gopher64

    export CARGO_BUNDLE_SKIP_BUILD=true
    app_path=$(cargo bundle --release | xargs)

    mkdir -p $out/Applications $out/bin
    mv $app_path $out/Applications/

    ln -s $out/Applications/Gopher64.app/Contents/MacOS/gopher64 $out/bin/gopher64

    runHook postInstall
  '';

  # Error: Os { code: 1, kind: PermissionDenied, message: "Operation not permitted" }
  doInstallCheck = !stdenv.hostPlatform.isDarwin;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool $out/Applications/Gopher64.app/Contents/MacOS/gopher64 \
      -add_rpath "${lib.makeLibraryPath [ moltenvk ]}"
  '';

  __structuredAttrs = true;

  cargoPatches = [
    # upstream rebuilds SDL3 from source
    # this patch makes it use the SDL3 library provided by nixpkgs
    ./use-sdl3-via-pkg-config.patch

    ./no-lto.patch
    ./no-git-describe.patch
    ./volk-linking-order.patch
    ./no-homebrew.patch
  ];

  meta = {
    description = "N64 emulator";
    homepage = "https://loganmc10.itch.io/gopher64";
    changelog = "https://github.com/gopher64/gopher64/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      prince213
      tomasajt
    ];

    mainProgram = "gopher64";
    downloadPage = "https://github.com/gopher64/gopher64/releases";
  };
})
