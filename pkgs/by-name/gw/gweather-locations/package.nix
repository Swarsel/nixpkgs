{
  lib,
  fetchurl,
  buildPackages,
  gettext,
  gnome,
  makeWrapper,
  meson,
  ninja,
  python3,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gweather-locations";
  version = "2026.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gweather-locations/${lib.versions.major finalAttrs.version}/gweather-locations-${finalAttrs.version}.tar.xz";
    hash = "sha256-51cKNmHgp1KgY4eyAyWFz1iPxWdwsfnznxpV0XsoNf4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs --build build-aux/gen_locations_variant.py
    wrapProgram $PWD/build-aux/gen_locations_variant.py \
      --prefix GI_TYPELIB_PATH : ${lib.getLib buildPackages.glib}/lib/girepository-1.0
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    (python3.pythonOnBuildForHost.withPackages (ps: [ ps.pygobject3 ]))
  ];

  __structuredAttrs = true;

  depsBuildBuild = [
    makeWrapper
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gweather-locations";
    };
  };

  meta = {
    description = "GWeather locations database";
    homepage = "https://gitlab.gnome.org/GNOME/gweather-locations";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
