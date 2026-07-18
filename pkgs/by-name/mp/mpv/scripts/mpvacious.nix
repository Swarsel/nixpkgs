{
  lib,
  fetchFromGitHub,
  buildLua,
  curl,
  gitUpdater,
  wl-clipboard,
  xclip,
}:

buildLua rec {
  pname = "mpvacious";
  version = "26.1.26.0";

  src = fetchFromGitHub {
    owner = "Ajatt-Tools";
    repo = "mpvacious";
    rev = "v${version}";
    sha256 = "sha256-I0h9tf1pwCkWPn/6t2mxhe4MPx6GsPR+F5F29NAgdXI=";
  };

  postPatch = ''
    substituteInPlace utils/forvo.lua \
      --replace-fail "'curl" "'${lib.getExe curl}"
    substituteInPlace platform/nix.lua \
      --replace-fail "'curl" "'${lib.getExe curl}" \
      --replace-fail "'wl-copy" "'${lib.getExe' wl-clipboard "wl-copy"}" \
      --replace-fail "'xclip" "'${lib.getExe xclip}"
  '';

  installPhase = ''
    runHook preInstall
    make PREFIX=$out/share/mpv install
    runHook postInstall
  '';

  passthru.scriptName = "mpvacious";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Adds mpv keybindings to create Anki cards from movies and TV shows";
    homepage = "https://github.com/Ajatt-Tools/mpvacious";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kmicklas ];
  };
}
