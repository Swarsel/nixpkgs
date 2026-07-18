{
  kauth,
  mkKdeDerivation,
  mpv,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kalarm";

  extraBuildInputs = [
    kauth
    mpv
  ];

  extraCmakeFlags = [
    "-DENABLE_LIBVLC=0"
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
