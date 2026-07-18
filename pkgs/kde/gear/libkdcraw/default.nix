{
  libraw,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "libkdcraw";
  extraBuildInputs = [ libraw ];
  extraNativeBuildInputs = [ pkg-config ];
}
