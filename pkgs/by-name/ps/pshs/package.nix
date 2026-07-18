{
  lib,
  stdenv,
  fetchFromGitHub,
  file,
  libevent,
  meson,
  miniupnpc,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  qrencode,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pshs";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "projg2";
    repo = "pshs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sfhhxeQa0rmBerfAemuHou0N001Zq5Hh7s7utxLQHOI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libevent
    file
    qrencode
    openssl
    miniupnpc
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pretty small HTTP server - a command-line tool to share files";
    homepage = "https://github.com/mgorny/pshs";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = lib.platforms.unix;
    mainProgram = "pshs";
  };
})
