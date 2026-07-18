{
  alsa-lib,
  libcanberra,
  libpulseaudio,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "kmix";

  extraBuildInputs = [
    alsa-lib
    libcanberra
    libpulseaudio
  ];
}
