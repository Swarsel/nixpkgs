{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  buildPackages,
  fetchpatch,
  gettext,
  libiconv,
  libtool,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmtp";
  version = "1.1.22";

  src = fetchFromGitHub {
    owner = "libmtp";
    repo = "libmtp";
    rev = "libmtp-${builtins.replaceStrings [ "." ] [ "-" ] finalAttrs.version}";
    sha256 = "sha256-hIH6W8qQ6DB4ST7SlFz6CCnLsEGOWgmUb9HoHMNA3wY=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  patches = [
    # gettext-0.25 support
    (fetchpatch {
      hash = "sha256-eXDNDHg8K+ZiO9n4RqQPJrh4V9GNiK/ZxZOA/oIX83M=";
      name = "gettext-0.25.patch";
      url = "https://github.com/libmtp/libmtp/commit/5e53ee68e61cc6547476b942b6aa9776da5d4eda.patch";
    })
    (fetchpatch {
      hash = "sha256-Skqr6REBl/Egf9tS5q8k5qmEhFY+rG2fymbiu9e4Mho=";
      name = "gettext-0.25-p2.patch";
      url = "https://github.com/libmtp/libmtp/commit/122eb9d78b370955b9c4d7618b12a2429f01b81a.patch";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    libtool
    pkg-config
  ];

  buildInputs = [ libiconv ];
  propagatedBuildInputs = [ libusb1 ];
  configureFlags = [ "--with-udev=${placeholder "out"}/lib/udev" ];

  makeFlags =
    lib.optionals (stdenv.hostPlatform.isLinux && !stdenv.buildPlatform.canExecute stdenv.hostPlatform)
      [
        "MTP_HOTPLUG=${buildPackages.libmtp}/bin/mtp-hotplug"
      ];

  preConfigure = ''
    autopoint -f
    NOCONFIGURE=1 ./autogen.sh
  '';

  doInstallCheck = true;

  configurePlatforms = [
    "build"
    "host"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Implementation of Microsoft's Media Transfer Protocol";

    longDescription = ''
      libmtp is an implementation of Microsoft's Media Transfer Protocol (MTP)
      in the form of a library suitable primarily for POSIX compliant operating
      systems. We implement MTP Basic, the stuff proposed for standardization.
    '';

    homepage = "https://github.com/libmtp/libmtp";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.unix;
  };
})
