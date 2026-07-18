{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "yt-dlg";
  version = "1.8.5";

  src = fetchFromGitHub {
    owner = "oleksis";
    repo = "youtube-dl-gui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-W1ZlArmM+Ro5MF/rB88me/PD79dJA4v188mPbMd8Kow=";
  };

  postInstall = ''
    install -Dm444 yt-dlg.desktop -t $out/share/applications
    cp -r youtube_dl_gui/data/* $out/share
  '';

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    pypubsub
    wxpython
  ];

  pyproject = true;
  pythonRelaxDeps = [ "wxpython" ];

  meta = {
    description = "Cross platform front-end GUI of the popular youtube-dl written in wxPython";
    homepage = "https://oleksis.github.io/youtube-dl-gui";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ quantenzitrone ];
    mainProgram = "yt-dlg";
  };
})
