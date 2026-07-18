{
  lib,
  cmark,
  hunspell,
  kdoctools,
  mkKdeDerivation,
  multimarkdown,
  pandoc,
  pkg-config,
  qt5compat,
  qtsvg,
  qttools,
  qtwebchannel,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "ghostwriter";

  extraBuildInputs = [
    qtsvg
    qttools
    qtwebchannel
    qtwebengine
    qt5compat
    kdoctools
    hunspell
  ];

  extraNativeBuildInputs = [ pkg-config ];

  qtWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      cmark
      multimarkdown
      pandoc
    ])
  ];

  meta.mainProgram = "ghostwriter";
}
