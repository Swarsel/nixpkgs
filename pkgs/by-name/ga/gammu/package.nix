{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  bluez,
  cmake,
  curl,
  dialog,
  gettext,
  glib,
  libgudev,
  libiconv,
  libusb1,
  pkg-config,
  replaceVars,
  sqlite,
  dbiSupport ? false,
  libdbi ? null,
  libdbi-drivers ? null,
  libpq ? null,
  postgresSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gammu";
  version = "1.43.2";

  src = fetchFromGitHub {
    owner = "gammu";
    repo = "gammu";
    rev = finalAttrs.version;
    sha256 = "sha256-+mZBELwFUEL4S3IUIIa83TaNIYQxjQE1TvWhXTcIfYc=";
  };

  patches = [
    ./bashcomp-dir.patch
    ./systemd.patch
    (replaceVars ./gammu-config-dialog.patch {
      dialog = "${dialog}/bin/dialog";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    bash
    bluez
    libusb1
    curl
    gettext
    glib
    sqlite
    libiconv
    libgudev
  ]
  ++ lib.optionals dbiSupport [
    libdbi
    libdbi-drivers
  ]
  ++ lib.optionals postgresSupport [ libpq ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    # Fix build with CMake 4
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  __structuredAttrs = true;

  meta = {
    description = "Command line utility and library to control mobile phones";
    homepage = "https://wammu.eu/gammu/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
