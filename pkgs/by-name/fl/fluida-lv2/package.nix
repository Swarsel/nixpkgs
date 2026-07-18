{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  fluidsynth,
  libx11,
  lv2,
  pkg-config,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fluida-lv2";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "Fluida.lv2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5Oud5s81DIc7p/GAJT3i8FHHBh4y9uJqOxfchmX1nE4=";
    # submodule: https://github.com/brummer10/libxputty.git
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
    pkg-config
  ];

  buildInputs = [
    cairo
    fluidsynth
    libx11
    lv2
  ];

  postInstall = ''
    # Output files were installed in ~/.lv2
    # copy to the output directory:
    mkdir -p $out/lib/lv2
    cp -r $HOME/.lv2/* $out/lib/lv2/
  '';

  meta = {
    description = "Fluidsynth as LV2 plugin";
    homepage = "https://github.com/brummer10/Fluida.lv2";
    changelog = "https://github.com/brummer10/Fluida.lv2/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ joostn ];
    platforms = [ "x86_64-linux" ];
  };
})
