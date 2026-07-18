{
  ffmpeg-full,
  ffmpegthumbs,
  frei0r,
  glaxnimate,
  kddockwidgets,
  kio-extras,
  libv4l,
  mkKdeDerivation,
  mlt,
  opentimelineio,
  pkg-config,
  qqc2-desktop-style,
  qtimageformats,
  qtmultimedia,
  qtnetworkauth,
  qtsvg,
  replaceVars,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "kdenlive";

  patches = [
    (replaceVars ./dependency-paths.patch {
      inherit mlt glaxnimate;
      ffmpeg = ffmpeg-full;
    })
  ];

  extraBuildInputs = [
    qtsvg
    qtmultimedia
    qtnetworkauth
    qtimageformats # UI uses webp images

    kddockwidgets
    qqc2-desktop-style
    kio-extras

    ffmpeg-full
    ffmpegthumbs
    libv4l
    mlt
    opentimelineio
  ];

  extraCmakeFlags = [
    "-DFETCH_OTIO=0"
  ];

  extraNativeBuildInputs = [
    pkg-config
    shared-mime-info
  ];

  qtWrapperArgs = [
    "--set FREI0R_PATH ${frei0r}/lib/frei0r-1"
  ];

  meta.mainProgram = "kdenlive";
}
