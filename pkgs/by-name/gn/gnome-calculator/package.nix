{
  lib,
  stdenv,
  fetchurl,
  appstream,
  blueprint-compiler,
  fetchpatch,
  gettext,
  glib,
  gmp,
  gnome,
  gsettings-desktop-schemas,
  gtk4,
  gtksourceview5,
  itstool,
  libadwaita,
  libgee,
  libmpc,
  libsoup_3,
  libxml2,
  meson,
  mpfr,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-calculator";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-calculator/${lib.versions.major finalAttrs.version}/gnome-calculator-${finalAttrs.version}.tar.xz";
    hash = "sha256-gFPWiRVl6IKHS2XB21HFvzEABet4i4usNUY5B0M1CpA=";
  };

  patches = [
    # Fix tests with GNU MPC 1.4.0
    (fetchpatch {
      hash = "sha256-FoV6SUprVdNcRORpoi+bNMTjzMM8bmXuze+6C9lqF8E=";
      url = "https://gitlab.gnome.org/GNOME/gnome-calculator/-/commit/c9bf69ce3688390a584ca7571ea5fcda5aea8863.patch";
    })
  ];

  nativeBuildInputs = [
    appstream
    blueprint-compiler
    meson
    ninja
    pkg-config
    vala
    gettext
    itstool
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    glib
    libxml2
    gtksourceview5
    mpfr
    gmp
    libgee
    gsettings-desktop-schemas
    libsoup_3
    libmpc
    libadwaita
  ];

  doCheck = true;

  preCheck = ''
    # Currency conversion test tries to store currency data in $HOME/.cache.
    export HOME=$TMPDIR
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-calculator";
    };
  };

  meta = {
    description = "Application that solves mathematical equations and is suitable as a default application in a Desktop environment";
    homepage = "https://apps.gnome.org/Calculator/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-calculator";
    teams = [ lib.teams.gnome ];
  };
})
