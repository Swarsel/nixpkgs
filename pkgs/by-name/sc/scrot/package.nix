{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  imlib2,
  libbsd,
  libx11,
  libxcomposite,
  libxext,
  libxfixes,
  libxinerama,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scrot";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "resurrecting-open-source-projects";
    repo = "scrot";
    tag = finalAttrs.version;
    hash = "sha256-ExZH+bjpEvdbSYM8OhV+cyn4j+0YrHp5/b+HsHKAHCA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
  ];

  buildInputs = [
    imlib2
    libx11
    libxext
    libxfixes
    libxcomposite
    libxinerama
    libbsd
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  meta = {
    description = "Command-line screen capture utility";
    homepage = "https://github.com/resurrecting-open-source-projects/scrot";
    license = lib.licenses.mitAdvertising;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.linux;
    mainProgram = "scrot";
  };
})
