{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scite";
  version = "5.6.1";

  src = fetchurl {
    url = "https://www.scintilla.org/scite${lib.replaceStrings [ "." ] [ "" ] finalAttrs.version}.tgz";
    hash = "sha256-Bune5B0v/WfWxFgM0cqOtUOhKDPLWJXKUK7JKckZS/A=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  makeFlags = [
    "GTK3=1"
    "prefix=${placeholder "out"}"
  ];

  env.CXXFLAGS = toString [
    # GCC 13: error: 'intptr_t' does not name a type
    "-include cstdint"
    "-include system_error"
  ];

  preBuild = ''
    pushd ../../scintilla/gtk
    make ''${makeFlags[@]}
    popd

    pushd ../../lexilla/src
    make ''${makeFlags[@]}
    popd
  '';

  enableParallelBuilding = true;
  sourceRoot = "scite/gtk";

  meta = {
    description = "SCIntilla based Text Editor";
    homepage = "https://www.scintilla.org/SciTE.html";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      rszibele
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "SciTE";
  };
})
