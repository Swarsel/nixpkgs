{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  buildPackages,
  bzip2,
  cargo,
  curl,
  gpm,
  libarchive,
  libunistring,
  nix-update-script,
  pcre2,
  re2c,
  readline,
  rustPlatform,
  rustc,
  sqlite,
  zlib,
  prqlSupport ? stdenv.hostPlatform == stdenv.buildPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lnav";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "tstack";
    repo = "lnav";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BP4QiGO6x2o+9hRvoB4gz1IfQbr/yLVHgT9PWX/k/3c=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    zlib
    curl.dev
    re2c
  ]
  ++ lib.optionals prqlSupport [
    cargo
    rustPlatform.cargoSetupHook
    rustc
  ];

  buildInputs = [
    bzip2
    pcre2
    readline
    sqlite
    curl
    libarchive
    libunistring
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    gpm
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = "${finalAttrs.src}/src/third-party/lnav-rs-ext";
    hash = "sha256-Dy+V45X27dy2TN3JRic6nLmmG11I1Pw7m+vYKYJMnQs=";
  };

  cargoRoot = "src/third-party/lnav-rs-ext";
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  separateDebugInfo = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^v(\\d+(?:\\.\\d+)*)$" ];
  };

  meta = {
    description = "Logfile Navigator";

    longDescription = ''
      The log file navigator, lnav, is an enhanced log file viewer that takes
      advantage of any semantic information that can be gleaned from the files
      being viewed, such as timestamps and log levels. Using this extra
      semantic information, lnav can do things like interleaving messages from
      different files, generate histograms of messages over time, and providing
      hotkeys for navigating through the file. It is hoped that these features
      will allow the user to quickly and efficiently zero in on problems.
    '';

    homepage = "https://github.com/tstack/lnav";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      dochang
      symphorien
      pcasaretto
    ];

    platforms = lib.platforms.unix;
    mainProgram = "lnav";
    downloadPage = "https://github.com/tstack/lnav/releases";
  };
})
