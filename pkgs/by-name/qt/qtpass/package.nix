{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  gnupg,
  libsForQt5,
  makeWrapper,
  pass,
  pwgen,
  qrencode,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtpass";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "IJHack";
    repo = "QtPass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0qbKM24v7xRiuBEs+rHP2l1W8bCl7uJRc3jzpDdjp/c=";
  };

  postPatch = ''
    substituteInPlace src/qtpass.cpp \
      --replace "/usr/bin/qrencode" "${qrencode}/bin/qrencode"
  '';

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    git
    gnupg
    pass
    libsForQt5.qtbase
    libsForQt5.qtsvg
  ];

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r main/QtPass.app $out/Applications
    makeWrapper $out/Applications/QtPass.app/Contents/MacOS/QtPass $out/bin/qtpass
    runHook postInstall
  '';

  postInstall = ''
    install -D qtpass.desktop -t $out/share/applications
    install -D artwork/icon.svg $out/share/icons/hicolor/scalable/apps/qtpass-icon.svg
    install -D qtpass.1 -t $out/share/man/man1
  '';

  qmakeFlags = [
    # setup hook only sets QMAKE_LRELEASE, set QMAKE_LUPDATE too:
    "QMAKE_LUPDATE=${libsForQt5.qttools.dev}/bin/lupdate"
  ];

  qtWrapperArgs = [
    "--suffix PATH : ${
      lib.makeBinPath [
        git
        gnupg
        pass
        pwgen
      ]
    }"
  ];

  meta = {
    description = "Multi-platform GUI for pass, the standard unix password manager";
    homepage = "https://qtpass.org";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.all;
    mainProgram = "qtpass";
  };
})
