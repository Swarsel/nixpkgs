{
  lib,
  stdenv,
  fetchFromGitHub,
  libqalculate,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qalculate-qt";
  version = "5.11.0";

  src = fetchFromGitHub {
    owner = "qalculate";
    repo = "qalculate-qt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5u/YA5/k7JQclIqJUKvzGEenEhndo52m23XlFjkhw78=";
  };

  postPatch = ''
    substituteInPlace qalculate-qt.pro\
      --replace "LRELEASE" "${qt6.qttools.dev}/bin/lrelease"
  '';

  nativeBuildInputs = with qt6; [
    qmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs =
    with qt6;
    [
      libqalculate
      qtbase
      qtsvg
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ qtwayland ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv $out/bin/qalculate-qt.app $out/Applications
    makeWrapper $out/{Applications/qalculate-qt.app/Contents/MacOS,bin}/qalculate-qt
  '';

  meta = {
    description = "Ultimate desktop calculator";
    homepage = "http://qalculate.github.io";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "qalculate-qt";
  };
})
