{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustc-demangle";
  version = "0.1.26";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "rustc-demangle";
    tag = "rustc-demangle-v${finalAttrs.version}";
    hash = "sha256-4/x3kUIKi3xnDRznr+6xmPeWHmhlpbuwSNH3Ej6+Ifc=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    # generated using `cargo generate-lockfile` since repo is missing lockfile
    lockFile = ./Cargo.lock;
  };

  postInstall = ''
    mkdir -p $out/lib
    cp target/${stdenv.hostPlatform.rust.rustcTargetSpec}/release/librustc_demangle${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib
    cp -R crates/capi/include $out
  '';

  cargoBuildFlags = [
    "-p"
    "rustc-demangle-capi"
  ];

  meta = {
    description = "Rust symbol demangling";
    homepage = "https://github.com/rust-lang/rustc-demangle";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ sledgehammervampire ];
    platforms = lib.platforms.unix;
  };
})
