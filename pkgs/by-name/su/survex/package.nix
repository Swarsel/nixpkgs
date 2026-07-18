{
  lib,
  stdenv,
  fetchurl,
  ffmpeg,
  gdal,
  glib,
  libGLU,
  libgbm,
  libice,
  libx11,
  perl,
  pkg-config,
  proj,
  python3,
  wrapGAppsHook3,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "survex";
  version = "1.4.22";

  src = fetchurl {
    url = "https://survex.com/software/${finalAttrs.version}/survex-${finalAttrs.version}.tar.gz";
    hash = "sha256-omli2IhiHP0gQ6fMaiJ/yQUTDfvRTEUNwcTAL7/dnbw=";
  };

  postPatch = ''
    patchShebangs .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    perl
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    ffmpeg
    glib
    proj
    gdal
    wxwidgets_3_2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # TODO: libGLU doesn't build for macOS because of Mesa issues
    # (#233265); is it required for anything?
    libGLU
    libgbm
    libice
    libx11
  ];

  configureFlags = [
    "WX_CONFIG=${lib.getExe' (lib.getDev wxwidgets_3_2) "wx-config"}"
  ];

  doCheck = (!stdenv.hostPlatform.isDarwin); # times out
  enableParallelBuilding = true;
  enableParallelChecking = false;

  meta = {
    description = "Free Software/Open Source software package for mapping caves";

    longDescription = ''
      Survex is a Free Software/Open Source software package for mapping caves,
      licensed under the GPL. It is designed to be portable and can be run on a
      variety of platforms, including Linux/Unix, macOS, and Microsoft Windows.
    '';

    homepage = "https://survex.com/";
    changelog = "https://github.com/ojwb/survex/raw/v${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.matthewcroughan ];
    platforms = lib.platforms.all;
  };
})
