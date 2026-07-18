{
  alsa-lib,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "libkcompactdisc";
  extraBuildInputs = [ alsa-lib ];
}
