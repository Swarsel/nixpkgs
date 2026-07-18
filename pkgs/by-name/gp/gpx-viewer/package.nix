{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  fetchpatch,
  gdl,
  libchamplain_libsoup3,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "gpx-viewer";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "DaveDavenport";
    repo = "gpx-viewer";
    rev = version;
    hash = "sha256-6AChX0UEIrQExaq3oo9Be5Sr13+POHFph7pZegqcjio=";
  };

  patches = [
    # Compile with libchamplain>=0.12.21
    (fetchpatch {
      hash = "sha256-2/r0M3Yxj+vWgny1Pd5G7NYMb0uC/ByZ7y3tqLVccOc=";
      url = "https://github.com/DaveDavenport/gpx-viewer/commit/12ed6003bdad840586351bdb4e00c18719873c0e.patch";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3 # Fix error: GLib-GIO-ERROR **: No GSettings schemas are installed on the system
  ];

  buildInputs = [
    gdl
    libchamplain_libsoup3
    adwaita-icon-theme
    libxml2
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Simple tool to visualize tracks and waypoints stored in a gpx file";
    homepage = "https://blog.sarine.nl/tag/gpxviewer/";
    changelog = "https://github.com/DaveDavenport/gpx-viewer/blob/${src.rev}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = with lib.platforms; linux;
    mainProgram = "gpx-viewer";
  };
}
