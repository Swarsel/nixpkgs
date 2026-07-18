{
  lib,
  stdenv,
  fetchurl,
  cmake,
  dbus,
  dbus-glib,
  pkg-config,
  python3Packages,
  qtbase,
  telepathy-farstream,
  telepathy-glib,
}:

let
  inherit (python3Packages) python dbus-python;
in
stdenv.mkDerivation rec {
  pname = "telepathy-qt";
  version = "0.9.8";

  src = fetchurl {
    url = "https://telepathy.freedesktop.org/releases/telepathy-qt/telepathy-qt-${version}.tar.gz";
    sha256 = "bf8e2a09060addb80475a4938105b9b41d9e6837999b7a00e5351783857e18ad";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    python
  ];

  buildInputs = [ dbus-glib ];

  propagatedBuildInputs = [
    qtbase
    telepathy-farstream
    telepathy-glib
  ];

  # No point in building tests if they are not run
  # On 0.9.7, they do not even build with QT4
  cmakeFlags = lib.optional (!doCheck) "-DENABLE_TESTS=OFF";
  doCheck = false; # giving up for now

  nativeCheckInputs = [
    dbus
    dbus-python
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Telepathy Qt bindings";
    homepage = "https://telepathy.freedesktop.org/components/telepathy-qt/";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
  };
}
