{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  hackrf,
  libbladeRF,
  libusb1,
  limesuite,
  ncurses,
  pkg-config,
  rtl-sdr,
  soapysdr-with-plugins,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dump1090";
  version = "10.2";

  src = fetchFromGitHub {
    owner = "flightaware";
    repo = "dump1090";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kTJ8FMugBRJaxWas/jEj4E5TmVnNpNdhq4r2YFFwgTU=";
  };

  patches = [
    # Fix compilation with GCC 15: https://github.com/flightaware/dump1090/pull/261
    (fetchpatch2 {
      hash = "sha256-x+U86b1j+mSpqfG4oFnHEz3cd7/O57ezPUf8yBrLzbc=";
      url = "https://github.com/flightaware/dump1090/commit/93be1da123215e8ac15a0deaffedd480e8899f77.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    hackrf
    libbladeRF
    libusb1
    ncurses
    rtl-sdr
    soapysdr-with-plugins
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux limesuite;

  buildFlags = [
    "DUMP1090_VERSION=${finalAttrs.version}"
    "showconfig"
    "dump1090"
    "view1090"
    "faup1090"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-implicit-function-declaration -Wno-int-conversion -Wno-unknown-warning-option";
  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -v dump1090 view1090 faup1090 $out/bin
    cp -vr public_html $out/share/dump1090

    runHook postInstall
  '';

  meta = {
    description = "Simple Mode S decoder for RTLSDR devices";
    homepage = "https://github.com/flightaware/dump1090";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      earldouglas
      aciceri
    ];

    platforms = lib.platforms.unix;
    mainProgram = "dump1090";
  };
})
