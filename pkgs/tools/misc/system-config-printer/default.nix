{
  lib,
  stdenv,
  fetchFromGitHub,
  atk,
  autoconf-archive,
  autoreconfHook,
  bash,
  cups,
  desktop-file-utils,
  docbook_xml_dtd_412,
  docbook_xsl,
  fetchpatch,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  libcupsfilters,
  libnotify,
  libsecret,
  libtool,
  libusb1,
  libxml2,
  packagekit,
  pango,
  pkg-config,
  python3Packages,
  udev,
  wrapGAppsHook3,
  xmlto,
}:

stdenv.mkDerivation rec {
  pname = "system-config-printer";
  version = "1.5.18";

  src = fetchFromGitHub {
    owner = "openPrinting";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-l3HEnYycP56vZWREWkAyHmcFgtu09dy4Ds65u7eqNZk=";
  };

  patches = [
    ./detect_serverbindir.patch
    # fix typeerror, remove on next release
    (fetchpatch {
      excludes = [ "NEWS" ];
      sha256 = "sha256-JCdGmZk2vRn3X1BDxOJaY3Aw8dr0ODVzi0oY20ZWfRs=";
      url = "https://github.com/OpenPrinting/system-config-printer/commit/399b3334d6519639cfe7f1c0457e2475b8ee5230.patch";
    })

    # switch to pep517 build tools
    ./pep517.patch

    # FIXME: remove when gettext is fixed
    ./gettext-0.25.patch
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    libtool
    autoconf-archive
    xmlto
    libxml2
    docbook_xml_dtd_412
    docbook_xsl
    desktop-file-utils
    python3Packages.wrapPython
    python3Packages.build
    python3Packages.installer
    python3Packages.setuptools
    python3Packages.wheel
    wrapGAppsHook3
    autoreconfHook
    gobject-introspection
  ];

  buildInputs = [
    glib
    udev
    libusb1
    cups
    python3Packages.python
    libnotify
    gdk-pixbuf
    pango
    atk
    packagekit
    libsecret
  ];

  configureFlags = [
    "--with-udev-rules"
    "--with-udevdir=${placeholder "out"}/etc/udev"
    "--with-systemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
  ];

  doCheck = true;

  postInstall = ''
    buildPythonPath "$out ''${pythonPath[*]}"
    gappsWrapperArgs+=(
      --prefix PATH : "$program_PATH"
      --set CUPS_DATADIR "${libcupsfilters}/share/cups"
    )

    find $out/share/system-config-printer -name \*.py -type f -perm -0100 -print0 | while read -d "" f; do
      patchPythonScript "$f"
    done
    patchPythonScript $out/etc/udev/udev-add-printer

    substituteInPlace $out/etc/udev/rules.d/70-printers.rules \
      --replace "udev-configure-printer" "$out/etc/udev/udev-configure-printer"
  '';

  doInstallCheck = true;

  prePatch = ''
    # for automake
    touch README ChangeLog
    # for tests
    substituteInPlace Makefile.am --replace /bin/bash ${bash}/bin/bash
  '';

  pythonPath =
    with python3Packages;
    requiredPythonModules [
      pycups
      pycurl
      dbus-python
      pygobject3
      pycairo
      pysmbc
    ];

  stripDebugList = [
    "bin"
    "lib"
    "etc/udev"
  ];

  meta = {
    homepage = "https://github.com/openprinting/system-config-printer";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
