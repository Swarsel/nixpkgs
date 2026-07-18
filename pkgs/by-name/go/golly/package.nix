{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  libGL,
  libGLU,
  libx11,
  python3,
  wrapGAppsHook3,
  wxwidgets_3_2,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "golly";
  version = "5.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/golly/golly/golly-${finalAttrs.version}/golly-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-WDXN5CgVP5uEC6lKQ1nlyybrMC56wBoJfNf1pcgwNhE=";
  };

  postPatch = ''
    substituteInPlace wxprefs.cpp \
      --replace-fail 'PYTHON_SHLIB' '${python3}/lib/libpython3.so'
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace makefile-gtk \
      --replace-fail '-Wl,--as-needed' "" \
      --replace-fail '-lGL ' "" \
      --replace-fail '-lGLU' ""
  '';

  nativeBuildInputs = [
    (python3.withPackages (ps: [
      ps.setuptools
      ps.distutils
    ]))
    wrapGAppsHook3
  ];

  buildInputs = [
    wxwidgets_3_2
    python3
    zlib
    libGLU
    libGL
    libx11
    SDL2
  ];

  makeFlags = [
    "-f"
    "makefile-gtk"
    "ENABLE_SOUND=1"
    "GOLLYDIR=${placeholder "out"}/share/golly"
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
    "CXXC=${stdenv.cc.targetPrefix}c++"
    "LD=${stdenv.cc.targetPrefix}c++"
    "WX_CONFIG=${lib.getExe' (lib.getDev wxwidgets_3_2) "wx-config"}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp ../golly ../bgolly "$out/bin"

    mkdir -p "$out/share/doc/golly/"
    cp ../docs/*  "$out/share/doc/golly/"

    mkdir -p "$out/share/golly"
    cp -r ../{Help,Patterns,Scripts,Rules} "$out/share/golly"

    runHook postInstall
  '';

  # fails nondeterministically on darwin
  enableParallelBuilding = false;

  setSourceRoot = ''
    sourceRoot=$(echo */gui-wx)
  '';

  meta = {
    description = "Cellular automata simulation program";
    homepage = "https://golly.sourceforge.io/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      raskin
      siraben
    ];

    platforms = lib.platforms.unix;
    downloadPage = "https://sourceforge.net/projects/golly/files/golly";
  };
})
