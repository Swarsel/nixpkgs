{
  lib,
  mkKdeDerivation,
  mpv-unwrapped,
  pkg-config,
  qtquick3d,
  qtsvg,
  yt-dlp,
}:
mkKdeDerivation {
  pname = "plasmatube";

  extraBuildInputs = [
    qtquick3d
    qtsvg
    mpv-unwrapped
  ];

  extraNativeBuildInputs = [ pkg-config ];

  qtWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ yt-dlp ])
  ];

  meta.mainProgram = "plasmatube";
}
