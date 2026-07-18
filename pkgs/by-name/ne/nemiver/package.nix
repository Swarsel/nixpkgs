{
  lib,
  stdenv,
  fetchurl,
  boost,
  fetchpatch,
  gdb,
  glibmm,
  gnome,
  gsettings-desktop-schemas,
  gtk3,
  gtkmm3,
  gtksourceview,
  gtksourceviewmm,
  intltool,
  itstool,
  libgtop,
  libxml2,
  pkg-config,
  sqlite,
  vte,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nemiver";
  version = "0.9.6";

  src = fetchurl {
    url = "mirror://gnome/sources/nemiver/${lib.versions.majorMinor finalAttrs.version}/nemiver-${finalAttrs.version}.tar.xz";
    sha256 = "85ab8cf6c4f83262f441cb0952a6147d075c3c53d0687389a3555e946b694ef2";
  };

  patches = [
    # build fixes
    (fetchpatch {
      sha256 = "1g0ixll6yqfj6ysf50p0c7nmh3lgmb6ds15703q7ibnw7dyidvj8";
      url = "https://gitlab.gnome.org/Archive/nemiver/-/commit/e0e42221ceb77d88be64fac1c09792dc5c9e2f43.patch";
    })
    (fetchpatch {
      sha256 = "1mxb1sdqdj7dm204gja8cdygx8579bjriqqbb7cna9rj0m9c8pjg";
      url = "https://gitlab.gnome.org/Archive/nemiver/-/commit/7005393a8c4d914eac9705e7f47818d0f4de3578.patch";
    })
    (fetchpatch {
      sha256 = "03jv6z54b8nzvplplapk4aj206zl1gvnv6iz0mad19g6yvfbw7a7";
      url = "https://gitlab.gnome.org/Archive/nemiver/-/commit/262cf9657f9c2727a816972b348692adcc666008.patch";
    })
  ];

  nativeBuildInputs = [
    libxml2
    intltool
    itstool
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gdb
    boost
    sqlite
    libgtop
    glibmm
    gtkmm3
    vte
    gtksourceview
    gtksourceviewmm
    gsettings-desktop-schemas
  ];

  configureFlags = [
    "--enable-gsettings"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "nemiver";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Easy to use standalone C/C++ debugger";
    homepage = "https://gitlab.gnome.org/Archive/nemiver";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.juliendehos ];
    platforms = lib.platforms.linux;
    mainProgram = "nemiver";
  };
})
