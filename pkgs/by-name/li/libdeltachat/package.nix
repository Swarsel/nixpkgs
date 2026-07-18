{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  cmake,
  deltachat-desktop,
  deltachat-repl,
  deltachat-rpc-server,
  fixDarwinDylibNames,
  libiconv,
  openssl,
  perl,
  pkg-config,
  python3,
  rustPlatform,
  sqlcipher,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdeltachat";
  version = "2.53.0";

  src = fetchFromGitHub {
    owner = "chatmail";
    repo = "core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W2Yh5+6MaJ47GqJioGKge2J3RetGGTcl+0YxPPlSdDo=";
  };

  patches = [
    ./no-static-lib.patch
  ];

  nativeBuildInputs = [
    cmake
    perl
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = [
    openssl
    sqlcipher
    sqlite
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  env = {
    CARGO_BUILD_RUSTFLAGS = "-C linker=${stdenv.cc.targetPrefix}cc";
    CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTarget;
  };

  nativeCheckInputs = with rustPlatform; [
    cargoCheckHook
  ];

  # Sometimes -fmacro-prefix-map= can redirect __FILE__ to non-existent
  # paths. This breaks packages like `python3.pkgs.deltachat`. We embed
  # absolute path to headers by expanding `__FILE__`.
  postInstall = ''
    substituteInPlace $out/include/deltachat.h \
      --replace __FILE__ '"${placeholder "out"}/include/deltachat.h"'
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) version src;
    pname = "chatmail-core";
    hash = "sha256-aoPc5XvjwwuA9aOTvIOpTm15wozC9glJGqn3vPqsJF4=";
  };

  passthru = {
    tests = {
      inherit deltachat-desktop deltachat-repl deltachat-rpc-server;
      python = python3.pkgs.deltachat;
    };
  };

  meta = {
    description = "Delta Chat Rust Core library";
    homepage = "https://github.com/chatmail/core";
    changelog = "https://github.com/chatmail/core/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.unix;
  };
})
