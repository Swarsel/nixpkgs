{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  pcre2,
  pkg-config,
  protobuf,
  replaceVars,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "holo-cli";
  version = "0.5.0-unstable-2026-03-15";

  src = fetchFromGitHub {
    owner = "holo-routing";
    repo = "holo-cli";
    rev = "36fdc13323e384c086da8663f0d510b238fb6e4f";
    hash = "sha256-5Nvyh9gznMsutu3wHR6gwgKkIm115hbx4R6D/Gm1Rug=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    pushd $cargoDepsCopy/*/libyang4-sys-*
    patch -p1 < ${
      replaceVars ./libyang4-sys.patch {
        PCRE2_INCLUDE_DIRS = "${lib.getInclude pcre2}/include";
        PCRE2_LIBRARIES = "${lib.getLib pcre2}/lib/libpcre2-8${stdenv.hostPlatform.extensions.sharedLibrary}";
      }
    }
    popd
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ];

  buildInputs = [
    pcre2
  ];

  cargoHash = "sha256-77aUfXcnVQLVEKQuUdBZ4k5/3rOoe9PvGC0AlJS0UJc=";
  # Use rust nightly features
  env.RUSTC_BOOTSTRAP = 1;

  cargoPatches = [
    # cargo lock is outdated
    # https://github.com/holo-routing/holo-cli/pull/31
    ./update-cargo-lock.patch
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Holo` Command Line Interface";
    homepage = "https://github.com/holo-routing/holo-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    platforms = lib.platforms.all;
    mainProgram = "holo-cli";
    teams = with lib.teams; [ ngi ];
  };
})
