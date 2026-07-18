{
  ffmpeg,
  kconfigwidgets,
  kparts,
  kxmlgui,
  mkKdeDerivation,
  pkg-config,
  qtmultimedia,
}:
mkKdeDerivation {
  pname = "dragon";

  extraBuildInputs = [
    qtmultimedia
    kconfigwidgets
    kparts
    kxmlgui
    ffmpeg
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "dragon";
}
