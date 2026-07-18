{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  doxygen,
  libtool,
  libusb-compat-0_1,
  libxslt,
  pcsclite,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openct";
  version = "0.6.20";

  src = fetchFromGitHub {
    owner = "OpenSC";
    repo = "openct";
    rev = "openct-${finalAttrs.version}";
    hash = "sha256-YloE4YsvvYwfwmMCsEMGctApO/ujyZP/iAz21iXAnSc=";
  };

  postPatch = ''
    substituteInPlace etc/Makefile.am \
      --replace-fail "DESTDIR" "out"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    doxygen
    libxslt # xsltproc
    pkg-config
  ];

  buildInputs = [
    pcsclite
    libtool # libltdl
    libusb-compat-0_1
  ];

  configureFlags = [
    "--enable-api-doc"
    "--enable-usb"
    "--enable-pcsc"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
  ];

  # unbreak build on GCC 14, remove when https://github.com/OpenSC/openct/pull/12
  # (or equivalent) is merged and released
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  preInstall = ''
    mkdir -p $out/etc
  '';

  meta = {
    description = "Drivers for several smart card readers";
    homepage = "https://github.com/OpenSC/openct/";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
