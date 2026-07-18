{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  libgcrypt,
  libimobiledevice-glue,
  libplist,
  libtasn1,
  libtatsu,
  libusbmuxd,
  openssl,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation rec {
  pname = "libimobiledevice";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "libimobiledevice";
    tag = version;
    hash = "sha256-SWWsa7asCXpcz80VNhxoePWr74QY8SP0byGSCp+nGG0=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  propagatedBuildInputs = [
    openssl
    libgcrypt
    libplist
    libtasn1
    libtatsu
    libusbmuxd
    libimobiledevice-glue
  ];

  configureFlags = [ "--without-cython" ];
  enableParallelBuilding = true;

  preAutoreconf = ''
    export RELEASE_VERSION=${version}
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Software library that talks the protocols to support iPhone®, iPod Touch® and iPad® devices on Linux";

    longDescription = ''
      libimobiledevice is a software library that talks the protocols to support
      iPhone®, iPod Touch® and iPad® devices on Linux. Unlike other projects, it
      does not depend on using any existing proprietary libraries and does not
      require jailbreaking. It allows other software to easily access the
      device's filesystem, retrieve information about the device and it's
      internals, backup/restore the device, manage SpringBoard® icons, manage
      installed applications, retrieve addressbook/calendars/notes and bookmarks
      and synchronize music and video to the device. The library is in
      development since August 2007 with the goal to bring support for these
      devices to the Linux Desktop.
    '';

    homepage = "https://github.com/libimobiledevice/libimobiledevice";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    platforms = lib.platforms.unix;
  };
}
