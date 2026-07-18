{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gobject-introspection,
  gtk-doc,
  gtk3,
  libayatana-indicator,
  libdbusmenu-gtk3,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libayatana-appindicator";
  version = "0.5.92";

  src = fetchFromGitHub {
    owner = "AyatanaIndicators";
    repo = "libayatana-appindicator";
    rev = finalAttrs.version;
    sha256 = "sha256-NzaWQBb2Ez1ik23wCgW1ZQh1/rY7GcPlLvaSgV7uXrA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    gtk-doc
    vala
    gobject-introspection
  ];

  buildInputs = [ gtk3 ];

  propagatedBuildInputs = [
    libayatana-indicator
    libdbusmenu-gtk3
  ];

  cmakeFlags = [
    "-DENABLE_BINDINGS_MONO=False"
  ];

  meta = {
    description = "Ayatana Application Indicators Shared Library";
    homepage = "https://github.com/AyatanaIndicators/libayatana-appindicator";
    changelog = "https://github.com/AyatanaIndicators/libayatana-appindicator/blob/${finalAttrs.version}/ChangeLog";

    license = [
      lib.licenses.lgpl3Plus
      lib.licenses.lgpl21Plus
    ];

    maintainers = [ lib.maintainers.nickhu ];
    platforms = lib.platforms.linux;
  };
})
