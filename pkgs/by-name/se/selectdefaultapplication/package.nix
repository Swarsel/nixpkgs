{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
}:

stdenv.mkDerivation {
  pname = "selectdefaultapplication";
  version = "unstable-2021-08-12";

  src = fetchFromGitHub {
    owner = "sandsmark";
    repo = "selectdefaultapplication";
    rev = "c752df6ba8caceeef54bcf6527f1bccc2ca8202a";
    sha256 = "C/70xpt6RoQNIlAjSJhOCyheolK4Xp6RiSZmeqMP4fw=";
  };

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [ libsForQt5.qtbase ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp selectdefaultapplication $out/bin

    install -Dm644 -t "$out/share/applications" selectdefaultapplication.desktop
    install -Dm644 -t "$out/share/icons/hicolor/48x48/apps" selectdefaultapplication.png

    runHook postInstall
  '';

  meta = {
    description = "Very simple application that lets you define default applications on Linux in a sane way";
    homepage = "https://github.com/sandsmark/selectdefaultapplication";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ nsnelson ];
    platforms = lib.platforms.linux;
    mainProgram = "selectdefaultapplication";
  };
}
