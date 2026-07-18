{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  boost,
  cfitsio,
  cmake,
  curl,
  fftw,
  gsl,
  gtest,
  indi-full,
  kmod,
  libev,
  libjpeg,
  libnova,
  libusb1,
  udevCheckHook,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "indilib";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "indilib";
    repo = "indi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XTb+etafMRTP/Arb087s+kZoqFT50RT1fpVDeHaGdmY=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    curl
    cfitsio
    libev
    libusb1
    zlib
    boost
    libnova
    libjpeg
    gsl
    fftw
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DUDEVRULES_INSTALL_DIR=lib/udev/rules.d"
  ]
  ++ lib.optional finalAttrs.finalPackage.doCheck [
    "-DINDI_BUILD_UNITTESTS=ON"
    "-DINDI_BUILD_INTEGTESTS=ON"
  ];

  # tests seem to be broken on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;
  checkInputs = [ gtest ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    udevCheckHook
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    for f in $out/lib/udev/rules.d/*.rules
    do
      substituteInPlace $f --replace-quiet "/bin/sh" "${bash}/bin/sh" \
                           --replace-quiet "/sbin/modprobe" "${kmod}/sbin/modprobe"
    done
  '';

  # Socket address collisions between tests
  enableParallelChecking = false;

  passthru.tests = {
    # make sure 3rd party drivers compile with this indilib
    indi-full = indi-full.override {
      indilib = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Implementation of the INDI protocol for POSIX operating systems";
    homepage = "https://www.indilib.org/";
    changelog = "https://github.com/indilib/indi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl2Plus;

    maintainers = with lib.maintainers; [
      sheepforce
      returntoreality
    ];

    platforms = lib.platforms.unix;
    mainProgram = "indiserver";
  };
})
