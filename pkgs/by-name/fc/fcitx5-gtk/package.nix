{
  lib,
  stdenv,
  fetchFromGitHub,
  at-spi2-core,
  cmake,
  dbus,
  fcitx5,
  fmt,
  glib,
  gobject-introspection,
  gtk2,
  gtk3,
  gtk4,
  kdePackages,
  libdatrie,
  libepoxy,
  libselinux,
  libsepol,
  libthai,
  libuuid,
  libxdmcp,
  libxkbcommon,
  libxtst,
  pkg-config,
  withGTK2 ? false,
}:

stdenv.mkDerivation rec {
  pname = "fcitx5-gtk";
  version = "5.1.7";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = pname;
    rev = version;
    hash = "sha256-ddXMkk1pQhFCOSzDbRWi/VDWtxqqKhMM4AnVFBGCOyA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk3
    gtk4
    fmt
    fcitx5
    libuuid
    libselinux
    libsepol
    libthai
    libdatrie
    libxdmcp
    libxkbcommon
    libepoxy
    dbus
    at-spi2-core
    libxtst
  ]
  ++ lib.optional withGTK2 gtk2;

  cmakeFlags = [
    "-DGOBJECT_INTROSPECTION_GIRDIR=share/gir-1.0"
    "-DGOBJECT_INTROSPECTION_TYPELIBDIR=lib/girepository-1.0"
  ]
  ++ lib.optional (!withGTK2) "-DENABLE_GTK2_IM_MODULE=off";

  meta = {
    description = "Fcitx5 gtk im module and glib based dbus client library";
    homepage = "https://github.com/fcitx/fcitx5-gtk";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
  };
}
