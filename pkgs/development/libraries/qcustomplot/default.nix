{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitLab,
  fixDarwinDylibNames,
  qmake,
  qtbase,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qcustomplot";
  version = "2.1.1";

  nativeBuildInputs = [
    qmake
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = [ qtbase ];
  env.LANG = "C.UTF-8";

  installPhase = ''
    runHook preInstall

    install -vDm 644 "qcustomplot.h" -t "$out/include/"
    install -vdm 755 "$out/lib/"
    cp -av libqcustomplot*${stdenv.hostPlatform.extensions.sharedLibrary}* "$out/lib/"

    runHook postInstall
  '';

  dontWrapQtApps = true;

  postUnpack = ''
    cp -rv source/* .
    cp -rv qcustomplot-source/* .
  '';

  qmakeFlags = [ "sharedlib/sharedlib-compilation/sharedlib-compilation.pro" ];
  sourceRoot = ".";

  srcs = [
    (fetchFromGitLab {
      hash = "sha256-BW8H/vDbhK3b8t8oB92icEBemzcdRdrIz2aKqlUi6UU=";
      owner = "ecme2";
      repo = "QCustomPlot";
      tag = "v${finalAttrs.version}";
    })
    (fetchurl {
      hash = "sha256-Xi0i3sd5248B81fL2yXlT7z5ca2u516ujXrSRESHGC8=";
      url = "https://www.qcustomplot.com/release/${finalAttrs.version}/QCustomPlot-source.tar.gz";
    })
  ];

  meta = {
    description = "Qt C++ widget for plotting and data visualization";
    homepage = "https://qtcustomplot.com/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Cryolitia ];
    platforms = lib.platforms.unix;
  };
})
