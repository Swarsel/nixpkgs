{
  lib,
  stdenv,
  fetchurl,
  buildPythonPackage,
  cairo,
  glib,
  gnome,
  gobject-introspection,
  meson,
  ncurses,
  ninja,
  pkg-config,
  pycairo,
  python,
}:

buildPythonPackage rec {
  pname = "pygobject";
  version = "3.56.3";

  src = fetchurl {
    url = "mirror://gnome/sources/pygobject/${lib.versions.majorMinor version}/pygobject-${version}.tar.gz";
    hash = "sha256-EnYOSg49BLbrleBveifjYsgm1WfqYTNzqSwAO2xw0tY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gobject-introspection
  ];

  buildInputs = [
    cairo
    glib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ ncurses ];

  propagatedBuildInputs = [
    pycairo
    gobject-introspection # e.g. try building: python3Packages.urwid python3Packages.pydbus
  ];

  mesonFlags = [
    # This is only used for figuring out what version of Python is in
    # use, and related stuff like figuring out what the install prefix
    # should be, but it does need to be able to execute Python code.
    "-Dpython=${python.pythonOnBuildForHost.interpreter}"
  ];

  # Fixes https://github.com/NixOS/nixpkgs/issues/378447
  preConfigure = lib.optionalString (stdenv.hostPlatform != stdenv.targetPlatform) ''
    export PKG_CONFIG_PATH=${lib.getDev python}/lib/pkgconfig:$PKG_CONFIG_PATH
    export PKG_CONFIG_PATH_FOR_BUILD=${lib.getDev python}/lib/pkgconfig:$PKG_CONFIG_PATH_FOR_BUILD
  '';

  depsBuildBuild = [ pkg-config ];
  pyproject = false;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "python3.pkgs.pygobject3";
      packageName = "pygobject";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Python bindings for Glib";
    homepage = "https://pygobject.readthedocs.io/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}
