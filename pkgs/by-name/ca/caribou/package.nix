{
  lib,
  stdenv,
  fetchurl,
  at-spi2-core,
  autoreconfHook,
  clutter,
  dbus,
  glib,
  gnome,
  gobject-introspection,
  gtk2,
  gtk3,
  intltool,
  libgee,
  libxklavier,
  libxml2,
  libxslt,
  libxtst,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [ pygobject3 ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "caribou";
  version = "0.4.21";

  src = fetchurl {
    url = "mirror://gnome/sources/caribou/${lib.versions.majorMinor finalAttrs.version}/caribou-${finalAttrs.version}.tar.xz";
    hash = "sha256-nEPZ9L0w9P6n94DU6LFPdYkQfFLpy2vSAr0NHCBk3lU=";
  };

  patches = [
    # Fix crash in GNOME Flashback
    # https://bugzilla.gnome.org/show_bug.cgi?id=791001
    (fetchurl {
      hash = "sha256-bU+/PTfkMh0KAUNCDhYYJ2iq9JlWLtwztdO4/EohYZY=";
      url = "https://bugzilla.gnome.org/attachment.cgi?id=364774";
    })
    # Stop patching the generated GIR, fixes build with latest vala
    (fetchurl {
      hash = "sha256-jbF1Ygp8Q0ENN/5aEpROuK5zkufIfn6cGW8dncl7ET4=";
      url = "https://gitlab.gnome.org/GNOME/caribou/-/commit/c52ce71c49dc8d6109a58d16cc8d491d7bd1d781.patch";
    })
    (fetchurl {
      hash = "sha256-XkyRYXWmlcHTx2q81WFUMXV273MKkG5DeTAhdOY/wmM=";
      name = "fix-build-modern-vala.patch";
      url = "https://gitlab.gnome.org/GNOME/caribou/-/commit/76fbd11575f918fc898cb0f5defe07f67c11ec38.patch";
    })
    (fetchurl {
      hash = "sha256-yIsEqSflpAdQPAB6eNr6fctxzyACu7N1HVfMIdCQou0=";
      name = "CVE-2021-3567.patch";
      url = "https://gitlab.gnome.org/GNOME/caribou/-/commit/d41c8e44b12222a290eaca16703406b113a630c6.patch";
    })
    # Fix build with gettext 0.25
    ./gettext-0.25.patch
  ];

  postPatch = ''
    patchShebangs .
    substituteInPlace libcaribou/Makefile.am --replace "--shared-library=libcaribou.so.0" "--shared-library=$out/lib/libcaribou.so.0"
  '';

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
    intltool
    libxslt
    libxml2
    pythonEnv
    autoreconfHook
    wrapGAppsHook3
    vala
  ];

  buildInputs = [
    glib
    gtk3
    clutter
    at-spi2-core
    dbus
    pythonEnv
    python3.pkgs.pygobject3
    libxtst
    gtk2
  ];

  propagatedBuildInputs = [
    libgee
    libxklavier
  ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    # This really should be done by latest Vala, but we are using
    # release tarball here, which dists generated C code.
    # https://gitlab.gnome.org/GNOME/vala/-/merge_requests/369
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  passthru = {
    updateScript = gnome.updateScript { packageName = "caribou"; };
  };

  meta = {
    description = "Input assistive technology intended for switch and pointer users";
    homepage = "https://gitlab.gnome.org/Archive/caribou";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "caribou-preferences";
    # checking for a Python interpreter with version >= 2.4... none
    # configure: error: no suitable Python interpreter found
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
})
