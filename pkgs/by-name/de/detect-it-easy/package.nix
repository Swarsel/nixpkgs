{
  lib,
  stdenv,
  fetchFromGitHub,
  freetype,
  graphite2,
  icu,
  imagemagick,
  krb5,
  libsForQt5,
  systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "detect-it-easy";
  version = "3.21";

  src = fetchFromGitHub {
    owner = "horsicq";
    repo = "DIE-engine";
    tag = finalAttrs.version;
    hash = "sha256-gst0suw5mNR3A0s/jIfte41cOOxKR0IsTFkO7ydwKMs=";
    fetchSubmodules = true;
  };

  postPatch = ''
        # Convert CRLF to LF so substituteInPlace works
        tr -d '\r' < XOptions/xoptions.cpp > XOptions/xoptions.cpp.tmp
        mv XOptions/xoptions.cpp.tmp XOptions/xoptions.cpp

        substituteInPlace XOptions/xoptions.cpp \
          --replace-fail 'QString XOptions::getApplicationDataPath()
    {
        QString sResult;' 'QString XOptions::getApplicationDataPath()
    {
    #if defined(Q_OS_LINUX)
        return qApp->applicationDirPath() + "/../lib/die";
    #endif
        QString sResult;'
  '';

  nativeBuildInputs = [
    libsForQt5.wrapQtAppsHook
    libsForQt5.qmake
    imagemagick
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtscript
    libsForQt5.qtsvg
    graphite2
    freetype
    icu
    krb5
    systemdLibs
  ];

  # work around wrongly created dirs in `install.sh`
  # https://github.com/horsicq/DIE-engine/issues/110
  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons
  '';

  postInstall = ''
    cp -r $src/XYara/yara_rules $out/lib/die/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Program for determining types of files for Windows, Linux and MacOS";
    homepage = "https://github.com/horsicq/Detect-It-Easy";
    changelog = "https://github.com/horsicq/Detect-It-Easy/blob/master/changelog.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "die";
  };
})
