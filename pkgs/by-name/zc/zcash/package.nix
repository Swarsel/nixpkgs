{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  boost,
  cargo,
  coreutils,
  curl,
  cxx-rs,
  db62,
  gitMinimal,
  hexdump,
  libevent,
  libsodium,
  llvmPackages,
  makeWrapper,
  pkg-config,
  rustPlatform,
  rustc,
  testers,
  tl-expected,
  utf8cpp,
  util-linux,
  zcash,
  zeromq,
}:
let
  stdenv = llvmPackages.stdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zcash";
  version = "5.4.2";

  src = fetchFromGitHub {
    owner = "zcash";
    repo = "zcash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XGq/cYUo43FcpmRDO2YiNLCuEQLsTFLBFC4M1wM29l8=";
  };

  patches = [
    # upstream has a custom way of specifying a cargo vendor-directory
    # we'll remove that logic, since cargoSetupHook from nixpkgs works better
    ./dont-use-custom-vendoring-logic.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    cargo
    cxx-rs
    gitMinimal
    hexdump
    makeWrapper
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    boost
    db62
    libevent
    libsodium
    tl-expected
    utf8cpp
    zeromq
  ];

  configureFlags = [
    "--disable-tests"
    "--with-boost-libdir=${lib.getLib boost}/lib"
    "RUST_TARGET=${stdenv.hostPlatform.rust.rustcTargetSpec}"
  ];

  env.CXXFLAGS = toString [
    "-I${lib.getDev utf8cpp}/include/utf8cpp"
    "-I${lib.getDev cxx-rs}/include"
  ];

  # Requires hundreds of megabytes of zkSNARK parameters.
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/zcash-fetch-params \
        --set PATH ${
          lib.makeBinPath [
            coreutils
            curl
            util-linux
          ]
        }
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-VBqasLpxqI4kr73Mr7OVuwb2OIhUwnY9CTyZZOyEElU=";
  };

  enableParallelBuilding = true;

  passthru.tests.version = testers.testVersion {
    version = "v${zcash.version}";
    command = "zcashd --version";
    package = zcash;
  };

  meta = {
    description = "Peer-to-peer, anonymous electronic cash system";
    homepage = "https://z.cash/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      tkerber
      centromere
    ];

    # https://github.com/zcash/zcash/issues/4405
    broken = stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isDarwin;
  };
})
