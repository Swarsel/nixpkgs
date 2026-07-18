{
  lib,
  stdenv,
  fetchFromGitHub,
  graphviz,
  libsForQt5,
  replaceVars,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qvge";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "ArsMasiuk";
    repo = "qvge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-011gJobDqNnXFTr/XSXcONxvPlzU7UEwS7CHkz1YMtY=";
  };

  patches = (
    replaceVars ./set-graphviz-path.patch {
      inherit graphviz;
    }
  );

  postPatch = ''
    substituteInPlace qvge/linux/qvge.desktop \
      --replace-warn "Exec=qvgeapp" "Exec=qvge"
  '';

  nativeBuildInputs = [
    libsForQt5.wrapQtAppsHook
    libsForQt5.qmake
  ];

  buildInputs =
    if stdenv.hostPlatform.isDarwin then [ libsForQt5.qtsvg ] else [ libsForQt5.qtx11extras ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv $out/bin/qvge.app $out/Applications
    ln -s $out/Applications/qvge.app/Contents/MacOS/qvge $out/bin/qvge
  '';

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Qt Visual Graph Editor";
    homepage = "https://github.com/ArsMasiuk/qvge";
    changelog = "https://github.com/ArsMasiuk/qvge/blob/v${finalAttrs.version}/CHANGES";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "qvge";
  };
})
