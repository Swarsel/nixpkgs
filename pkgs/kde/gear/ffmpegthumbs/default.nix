{
  ffmpeg,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "ffmpegthumbs";
  extraBuildInputs = [ ffmpeg ];
  extraNativeBuildInputs = [ pkg-config ];
}
