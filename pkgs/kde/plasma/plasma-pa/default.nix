{
  libcanberra,
  mkKdeDerivation,
  pkg-config,
  pulseaudio,
}:
mkKdeDerivation {
  pname = "plasma-pa";

  extraBuildInputs = [
    libcanberra
    pulseaudio
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
