{
  mkKdeDerivation,
  pkg-config,
  qtmultimedia,
  qtsvg,
  qtwebsockets,
  qtwebview,
  sonnet,
}:
mkKdeDerivation {
  pname = "tokodon";

  extraBuildInputs = [
    qtmultimedia
    qtsvg
    qtwebsockets
    qtwebview
    sonnet
  ];

  extraCmakeFlags = [ "-DUSE_QTMULTIMEDIA=1" ];
  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "tokodon";
}
