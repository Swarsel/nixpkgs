{
  lib,
  stdenv,
  fetchFromGitHub,
  ffmpeg_6,
  git,
  nix-update-script,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pencil2d";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "pencil2d";
    repo = "pencil";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OZlDx+L3kIIp9c2iXvfxLKEJntOA6sji5ugwZXnUqRA=";
    leaveDotGit = true;

    postFetch = ''
      # Obtain the last commit ID and its timestamp, then zap .git for reproducibility
      cd $out
      git rev-parse HEAD > $out/COMMIT
      # 0000-00-00T00:00:00Z
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%d_%H:%M:%S" > $out/SOURCE_TIMESTAMP_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  patches = [ ./git-inherit.patch ];

  nativeBuildInputs = with qt5; [
    qmake
    wrapQtAppsHook
    qttools
    git
  ];

  buildInputs = with qt5; [
    qtbase
    qtmultimedia
    qtsvg
    qtwayland
    ffmpeg_6
  ];

  qmakeFlags = [
    "pencil2d.pro"
    "CONFIG+=release"
    "CONFIG+=PENCIL2D_RELEASE"
    "CONFIG+=GIT"
    "VERSION=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Easy, intuitive tool to make 2D hand-drawn animations";
    homepage = "https://www.pencil2d.org/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ agvantibo ];
    platforms = lib.platforms.linux;
    mainProgram = "pencil2d";
    downloadPage = "https://github.com/pencil2d/pencil";
  };
})
