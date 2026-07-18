{
  lib,
  stdenv,
  fetchFromGitHub,
  beets,
  cmake,
  glib,
  gtk3,
  libgee,
  libxml2,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "supergee";
  version = "0-unstable-2023-11-21";

  src = fetchFromGitHub {
    owner = "DannyGB";
    repo = "SuperGee";
    rev = "c1232f6a8a9d4161644d728df793ffd3cb5cc4af";
    hash = "sha256-lv7C4ku3MdiHxg1LfmnzT5Sx3DTtvP9g3XPOQlNBDkg=";
  };

  postPatch = ''
    substituteInPlace BeetService.vala \
      --replace-fail '"beet"' '"${lib.getExe beets}"'
  '';

  nativeBuildInputs = [
    meson
    ninja
    libxml2.bin
    vala
    pkg-config
    cmake
    glib.bin
  ];

  buildInputs = [
    gtk3
    libgee
    glib
  ];

  preConfigure = ''
    pushd ..
    find -exec chmod +w {} \;
    mkdir build
    cd build
    mkdir SuperG@exe
    glib-compile-resources --sourcedir ../resources --generate-source --target SuperG@exe/resources.c ../resources/superg.gresource.xml
    popd
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 SuperG $out/bin/SuperG

    runHook postInstall
  '';

  dontUseCmakeConfigure = true;
  sourceRoot = "${finalAttrs.src.name}/src";

  passthru = {
    updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
  };

  meta = {
    description = "Vala based UI for beets";
    homepage = "https://github.com/DannyGB/SuperGee";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "SuperG";
  };
})
