{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qhexedit2";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "Simsys";
    repo = "qhexedit2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GIBpdycuQ0F/rlyRznS02nE1kfR4GedZuTrGIwE9AoU=";
  };

  postPatch = ''
    # Replace QPallete::Background with QPallete::Window in all files, since QPallete::Background was removed in Qt 6
    find . -type f -exec sed -i 's/QPalette::Background/QPalette::Window/g' {} +
  '';

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
    qt6.qtwayland
  ];

  # A custom installPhase is needed because no [native] build input provides an installPhase hook
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp qhexedit $out/bin

    runHook postInstall
  '';

  qmakeFlags = [
    "./example/qhexedit.pro"
  ];

  passthru = {
    updateScript = nix-update-script { };
    # I would use testers.testVersion except for some reason it fails, even with my patches that add a --version flag
    # TODO: Debug why testVersion reports a non-zero status code in the nix sandbox
  };

  meta = {
    description = "Hex Editor for Qt";
    homepage = "https://github.com/Simsys/qhexedit2";
    changelog = "https://github.com/Simsys/qhexedit2/releases";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ pandapip1 ];
    platforms = lib.platforms.all;
    mainProgram = "qhexedit";
  };
})
