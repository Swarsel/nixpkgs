{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libimobiledevice-glue,
  libusb1,
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libirecovery";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "libirecovery";
    rev = finalAttrs.version;
    hash = "sha256-CSDG8mOLvKAIpxmZnNLMKY1HvQIqk66/rkjmzq7F8vY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libusb1
    readline
    libimobiledevice-glue
  ];

  # Packager note: Not clear whether this needs a NixOS configuration,
  # as only the `idevicerestore` binary was tested so far (which worked
  # without further configuration).
  configureFlags = [
    "--with-udevrulesdir=${placeholder "out"}/lib/udev/rules.d"
    ''--with-udevrule=OWNER="root",GROUP="myusergroup",MODE="0660"''
  ];

  doInstallCheck = true;

  preAutoreconf = ''
    export RELEASE_VERSION=${finalAttrs.version}
  '';

  meta = {
    description = "Library and utility to talk to iBoot/iBSS via USB on Mac OS X, Windows, and Linux";

    longDescription = ''
      libirecovery is a cross-platform library which implements communication to
      iBoot/iBSS found on Apple's iOS devices via USB. A command-line utility is also
      provided.
    '';

    homepage = "https://github.com/libimobiledevice/libirecovery";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ nh2 ];
    platforms = lib.platforms.unix;
    mainProgram = "irecovery";
  };
})
