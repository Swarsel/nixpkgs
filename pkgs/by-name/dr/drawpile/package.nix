{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  cmake,
  fetchpatch,
  # client deps
  ffmpeg,
  # optional client deps
  giflib,
  kdePackages,
  # optional server deps
  libmicrohttpd,
  libsecret,
  libsodium,
  libvpx,
  libwebp,
  # common deps
  libzip,
  miniupnpc,
  pkg-config,
  qt6Packages,
  rustPlatform,
  rustc,
  # options
  buildClient ? true,
  buildExtraTools ? false,
  buildServer ? true,
  buildServerGui ? true, # if false builds a headless server
  systemd ? null,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

assert lib.assertMsg (
  buildClient || buildServer || buildExtraTools
) "You must specify at least one of buildClient, buildServer, or buildExtraTools.";

let
  clientDeps = with qt6Packages; [
    qtbase
    qtkeychain
    qtmultimedia
    qtsvg
    qttools
    ffmpeg
    libsecret
    libwebp
    # optional:
    giflib # gif animation export support
    libvpx # WebM video export
    miniupnpc # automatic port forwarding
  ];

  serverDeps = [
    # optional:
    libmicrohttpd # HTTP admin api
    libsodium # ext-auth support
  ]
  ++ lib.optional withSystemd systemd;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "drawpile";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "drawpile";
    repo = "drawpile";
    rev = finalAttrs.version;
    sha256 = "sha256-0paLKxAEvlbExq426xTekBt+Dkphx7Wg/AtpYN3f/4w=";
  };

  patches = [
    # Remove for 2.3.1
    # QT updated and broke some functionality so we have to get the commit that fixes it from upstream
    (fetchpatch {
      hash = "sha256-Z8mcPux8tvK5y1GirfKq1X9+kxHDIrnSLTd2MCSIxTg=";
      name = "qt-6.10.1.patch";
      url = "https://github.com/drawpile/Drawpile/commit/c4f69f79b1cb0d25e68b49e807ce6773ddb9dd3c.patch";
    })
  ];

  nativeBuildInputs = [
    cargo
    pkg-config
    cmake
    kdePackages.extra-cmake-modules
    rustc
    rustPlatform.cargoSetupHook
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    libzip
    qt6Packages.qtwebsockets
  ]
  ++ lib.optionals buildClient clientDeps
  ++ lib.optionals buildServer serverDeps;

  cmakeFlags = [
    (lib.cmakeFeature "INITSYS" (lib.optionalString withSystemd "systemd"))
    (lib.cmakeBool "CLIENT" buildClient)
    (lib.cmakeBool "SERVER" buildServer)
    (lib.cmakeBool "SERVERGUI" buildServerGui)
    (lib.cmakeBool "TOOLS" buildExtraTools)
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-u9fRbxKeQSou9Umw4EaqzzzDiN4zhyfx9sWnlZpfpxU=";
  };

  meta = {
    description = "Collaborative drawing program that allows multiple users to sketch on the same canvas simultaneously";
    homepage = "https://drawpile.net/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      fgaz
      qubic
    ];

    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
    downloadPage = "https://drawpile.net/download/";
  }
  // lib.optionalAttrs buildServer {
    mainProgram = "drawpile-srv";
  }
  // lib.optionalAttrs buildClient {
    mainProgram = "drawpile";
  };
})
