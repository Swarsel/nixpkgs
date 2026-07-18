{
  lib,
  stdenv,
  fetchurl,
  cairomm_1_16,
  glibmm_2_68,
  gnome,
  meson,
  ninja,
  pango,
  pkg-config,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "pangomm";
  version = "2.56.1";

  src = fetchurl {
    url = "mirror://gnome/sources/pangomm/${lib.versions.majorMinor version}/pangomm-${version}.tar.xz";
    hash = "sha256-U59apg6b3GuVW7RI4qYswUVidE32kCWAQPu3S/iFdV0=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    python3
  ];

  propagatedBuildInputs = [
    pango
    glibmm_2_68
    cairomm_1_16
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "pangomm_2_48";
      packageName = "pangomm";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "C++ interface to the Pango text rendering library";

    longDescription = ''
      Pango is a library for laying out and rendering of text, with an
      emphasis on internationalization.  Pango can be used anywhere
      that text layout is needed, though most of the work on Pango so
      far has been done in the context of the GTK widget toolkit.
      Pango forms the core of text and font handling for GTK.
    '';

    homepage = "https://www.pango.org/";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}
