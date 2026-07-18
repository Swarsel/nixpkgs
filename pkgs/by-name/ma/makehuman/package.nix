{
  lib,
  stdenv,
  fetchFromGitHub,
  git-lfs,
  libsForQt5,
  python3,
}:

let
  pydeps = with python3.pkgs; [
    numpy
    pyqt5
    pyopengl
  ];
  python = python3.withPackages (pkgs: pydeps);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "makehuman";
  version = "1.3.0";

  nativeBuildInputs = [
    python
    libsForQt5.qtbase
    git-lfs
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    python
    libsForQt5.qtbase
  ];

  propagatedBuildInputs = pydeps;

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/opt $out/bin
    cp -r * $out/opt
    python -m compileall -o 0 -o 2 $out/opt
    ln -s $out/opt/makehuman/makehuman.py $out/bin/makehuman
    chmod +x $out/bin/makehuman
    runHook postBuild
  '';

  preFixup = ''
    wrapQtApp $out/bin/makehuman
  '';

  assets = fetchFromGitHub {
    hash = "sha256-Jd2A0PAHVdFMnDLq4Mu5wsK/E6A4QpKjUyv66ix1Gbo=";
    name = "makehuman-assets-source";
    owner = "makehumancommunity";
    repo = "makehuman-assets";
    tag = "v${finalAttrs.version}";
  };

  configurePhase = ''
    runHook preConfigure
    pushd ./makehuman
    bash ./cleannpz.sh
    bash ./cleanpyc.sh
    python3 ./compile_targets.py
    python3 ./compile_models.py
    python3 ./compile_proxies.py
    popd
    runHook postConfigure
  '';

  finalSource = "makehuman-final";

  postUnpack = ''
    mkdir -p $finalSource
    cp -r $source/makehuman $finalSource
    chmod u+w $finalSource --recursive
    cp -r $assets/base/* $finalSource/makehuman/data
    chmod u+w $finalSource --recursive
    sourceRoot=$finalSource
  '';

  source = fetchFromGitHub {
    hash = "sha256-x0v/SkwtOl1lkVi2TRuIgx2Xgz4JcWD3He7NhU44Js4=";
    name = "makehuman-source";
    owner = "makehumancommunity";
    repo = "makehuman";
    tag = "v${finalAttrs.version}";
  };

  sourceRoot = ".";

  srcs = with finalAttrs; [
    source
    assets
  ];

  meta = {
    description = "Software to create realistic humans";

    longDescription = ''
      MakeHuman is a GUI program for procedurally generating
      realistic-looking humans.
    '';

    homepage = "http://www.makehumancommunity.org/";

    license = with lib.licenses; [
      agpl3Plus
      cc0
    ];

    maintainers = with lib.maintainers; [ elisesouche ];
    platforms = lib.platforms.all;
    mainProgram = "makehuman";
    broken = true; # Added 2026-05-12
  };
})
