{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  cmake,
  curl,
  gettext,
  git,
  gtk3,
  lsb-release,
  lua,
  makeWrapper,
  pkg-config,
  sqlite,
  wrapGAppsHook3,
  wxsqlite3,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "money-manager-ex";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "moneymanagerex";
    repo = "moneymanagerex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DE235wSfq20X3qh2L0KfFLk/54CW6l4Qn1K5r9nePQg=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/dbwrapper.cpp src/model/Model_Report.cpp \
      --replace-fail "sqlite3mc_amalgamation.h" "sqlite3.h"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    appstream # for appstreamcli
    cmake
    gettext
    git
    makeWrapper
    pkg-config
    wrapGAppsHook3
    wxwidgets_3_2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    lsb-release
  ];

  buildInputs = [
    curl
    sqlite
    wxwidgets_3_2
    gtk3
    lua
    wxsqlite3
  ];

  cmakeFlags = [
    "-DWXSQLITE3_HAVE_CODEC=1"
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [
      "-Wno-deprecated-copy"
      "-Wno-old-style-cast"
      "-Wno-unused-parameter"
    ]
  );

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/{Applications,bin}
    mv $out/mmex.app $out/Applications
    makeWrapper $out/{Applications/mmex.app/Contents/MacOS,bin}/mmex
  '';

  meta = {
    description = "Easy-to-use personal finance software";
    homepage = "https://www.moneymanagerex.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
    mainProgram = "mmex";
  };
})
