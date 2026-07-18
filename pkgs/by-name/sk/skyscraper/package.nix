{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  mdbtools,
  p7zip,
  python3,
  qt6,
  sqlite,
  # Whether to compile with XDG support
  # (See: https://gemba.github.io/skyscraper/XDG/)
  enableXdg ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "skyscraper";
  version = "3.18.5";

  src = fetchFromGitHub {
    owner = "Gemba";
    repo = "skyscraper";
    tag = finalAttrs.version;
    hash = "sha256-lX+ew/PkZdOFjYDVLCsF3JH8oqQBAjxfZQegHZ1vcDo=";
  };

  postPatch = lib.optionalString enableXdg ''
    substituteInPlace skyscraper.pro --replace-fail "#DEFINES+=XDG" "DEFINES+=XDG"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    qt6.qmake
    installShellFiles
  ];

  buildInputs = [
    qt6.qtbase
    mdbtools
    sqlite
    python3
  ];

  env.PREFIX = placeholder "out";

  postInstall = ''
    installShellCompletion --cmd Skyscraper \
      --bash supplementary/bash-completion/Skyscraper.bash
  '';

  preFixup = ''
    qtWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ p7zip ]})
    chmod +x $out/bin/*.py
    sed -i '2i\\export PATH="${
      lib.makeBinPath [
        mdbtools
        sqlite
      ]
    }:$PATH"' \
      $out/bin/mdb2sqlite.sh
  '';

  meta = {
    description = "Powerful and versatile game data scraper written in Qt and C++";
    homepage = "https://gemba.github.io/skyscraper/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ashgoldofficial ];
    platforms = lib.platforms.linux;
    mainProgram = "Skyscraper";
    downloadPage = "https://github.com/Gemba/skyscraper/releases/tag/${finalAttrs.version}";
  };
})
