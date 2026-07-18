{
  libgphoto2,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kamera";
  extraBuildInputs = [ libgphoto2 ];
  extraNativeBuildInputs = [ pkg-config ];
}
