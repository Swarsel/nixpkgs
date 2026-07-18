{
  lib,
  stdenv,
  fetchFromGitHub,
  # Configure
  autoreconfHook,
  fftwFloat,
  # Build libraries
  gtk3,
  libjack2,
  # Build binaries
  pkg-config,
  portaudio,
  python3,
  wrapGAppsHook3,
  # Check Binaries
  xvfb-run,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tg-timer";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "xyzzy42";
    repo = "tg";
    tag = "v${finalAttrs.version}-tpiepho";
    hash = "sha256-9QeTjr/J0Y10YfPKEfYnciu5z2+hmmWFKLdw6CCS3hU=";
  };

  patches = [
    ./audio.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    wrapGAppsHook3
    autoreconfHook
    pkg-config
    (python3.pythonOnBuildForHost.withPackages (p: [
      p.numpy
      p.matplotlib
      p.libtfr
      p.scipy
    ]))
  ];

  buildInputs = [
    gtk3
    portaudio
    fftwFloat
    libjack2
  ];

  doCheck = true;

  nativeCheckInputs = [
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck

    xvfb-run -s '-screen 0 800x600x24' \
    make -j "$NIX_BUILD_CORES" test

    runHook postCheck
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "for timing mechanical watches";
    homepage = "https://github.com/xyzzy42/tg";
    changelog = "https://github.com/xyzzy42/tg/releases/tag/v${finalAttrs.version}-tpiepho";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ RossSmyth ];
    mainProgram = "tg-timer";
  };
})
