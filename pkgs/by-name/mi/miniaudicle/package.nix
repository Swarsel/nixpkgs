{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  bison,
  flex,
  kdePackages,
  libjack2,
  libpulseaudio,
  libsndfile,
  which,
  audioBackend ? "pulse", # "pulse", "alsa", or "jack"
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "miniaudicle";
  version = "1.5.4.2";

  src = fetchFromGitHub {
    owner = "ccrma";
    repo = "miniAudicle";
    tag = "chuck-${finalAttrs.version}";
    hash = "sha256-LYr9Fc4Siqk0BFKHVXfIV2XskJYAN+/0P+nb6FJLsLE=";
    fetchSubmodules = true;
  };

  postPatch = ''
    echo '#define GIT_REVISION "${finalAttrs.version}-NixOS"' > git-rev.h
    substituteInPlace miniAudicle.pro \
      --replace-fail "/usr/local" $out
  '';

  nativeBuildInputs = [
    bison
    flex
    which
    kdePackages.qmake
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    libsndfile
    kdePackages.qscintilla
  ]
  ++ lib.optional (audioBackend == "pulse") libpulseaudio
  ++ lib.optional (audioBackend == "jack") libjack2;

  buildFlags = [ "linux-${audioBackend}" ];
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Light-weight integrated development environment for the ChucK digital audio programming language";
    homepage = "https://audicle.cs.princeton.edu/mini/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "miniAudicle";
    broken = stdenv.hostPlatform.isDarwin; # not attempted
    downloadPage = "https://audicle.cs.princeton.edu/mini/linux/";
  };
})
