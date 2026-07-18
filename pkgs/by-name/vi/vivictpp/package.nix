{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_ttf,
  cacert,
  cmake,
  ffmpeg,
  freetype,
  git,
  harfbuzz,
  libx11,
  meson,
  ninja,
  nix-update,
  pkg-config,
  python3,
  writeShellScript,
  zlib,
}:

let
  version = "1.3.2";
  withSubprojects = stdenv.mkDerivation {
    inherit version;
    pname = "sources-with-subprojects";

    src = fetchFromGitHub {
      owner = "vivictorg";
      repo = "vivictpp";
      tag = "v${version}";
      hash = "sha256-s93tqsXiU7NESI594tmHE/2ymaE68lcaGSOM2GDHPLU=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      meson
      cacert
      git
    ];

    buildCommand = ''
      cp -r --no-preserve=mode $src $out
      cd $out

      meson subprojects download
      find subprojects -type d -name .git -prune -execdir rm -r {} +
    '';

    outputHash = "sha256-RQRlH+wByWRfVyVR/kjjUm9/fLXUupd2yRK80FogzRM=";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "vivictpp";
  src = withSubprojects;

  nativeBuildInputs = [
    meson
    cmake
    ninja
    pkg-config

    python3
    git
  ];

  buildInputs = [
    SDL2
    libx11
    SDL2_ttf
    freetype
    harfbuzz
    ffmpeg
    zlib
  ];

  preConfigure = ''
    patchShebangs .
  '';

  passthru.updateScript = writeShellScript "update-vivictpp" ''
    ${lib.getExe nix-update} vivictpp.src
    ${lib.getExe nix-update} vivictpp --version skip
  '';

  meta = {
    description = "Easy to use tool for subjective comparison of the visual quality of different encodings of the same video source";
    homepage = "https://github.com/vivictorg/vivictpp";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ tilpner ];
    platforms = lib.platforms.unix;
    mainProgram = "vivictpp";
  };
}
