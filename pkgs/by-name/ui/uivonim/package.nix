{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  electron,
  makeWrapper,
}:

buildNpmPackage rec {
  pname = "uivonim";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "smolck";
    repo = "uivonim";
    rev = "v${version}";
    hash = "sha256-TcsKjRwiCTRQLxolRuJ7nRTGxFC0V2Q8LQC5p9iXaaY=";
  };

  nativeBuildInputs = [ makeWrapper ];
  npmDepsHash = "sha256-jWLvsN6BCxTWn/Lc0fSz0VJIUiFNN8ptSYMeWlWsHXc=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/uivonim \
      --add-flags $out/lib/node_modules/uivonim/build/main/main.js
  '';

  npmBuildScript = "build:prod";
  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Cross-platform GUI for neovim based on electron";
    homepage = "https://github.com/smolck/uivonim";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "uivonim";
  };
}
