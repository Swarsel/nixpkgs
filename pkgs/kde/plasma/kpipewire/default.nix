{
  ffmpeg,
  libgbm,
  libva,
  mkKdeDerivation,
  pipewire,
  pkg-config,
  qtquick3d,
}:
mkKdeDerivation {
  pname = "kpipewire";

  extraBuildInputs = [
    qtquick3d
    pipewire
    ffmpeg
    libgbm
    libva
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
