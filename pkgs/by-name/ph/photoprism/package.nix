{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  darktable,
  exiftool,
  fetchzip,
  ffmpeg,
  imagemagick,
  libheif,
  librsvg,
  makeWrapper,
  nixosTests,
  rawtherapee,
  testers,
}:

let
  version = "251130-b3068414c";
  pname = "photoprism";

  src = fetchFromGitHub {
    owner = "photoprism";
    repo = "photoprism";
    rev = version;
    hash = "sha256-8yg5CtvBtSKRaOUj9f+Db7rruXIVuF2cR50vZ+WUU6A=";
  };

  backend = callPackage ./backend.nix { inherit src version; };
  frontend = callPackage ./frontend.nix { inherit src version; };

  fetchModel =
    { hash, name }:
    fetchzip {
      inherit hash;
      stripRoot = false;
      url = "https://dl.photoprism.app/tensorflow/${name}.zip";
    };

  facenet = fetchModel {
    hash = "sha256-aS5kkNhxOLSLTH/ipxg7NAa1w9X8iiG78jmloR1hpRo=";
    name = "facenet";
  };

  nasnet = fetchModel {
    hash = "sha256-bF25jPmZLyeSWy/CGXZE/VE2UupEG2q9Jmr0+1rUYWE=";
    name = "nasnet";
  };

  nsfw = fetchModel {
    hash = "sha256-zy/HcmgaHOY7FfJUY6I/yjjsMPHR2Ote9ppwqemBlfg=";
    name = "nsfw";
  };

  assets_path = "$out/share/photoprism";
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin ${assets_path}

    # install backend
    ln -s ${backend}/bin/photoprism $out/bin/photoprism
    wrapProgram $out/bin/photoprism \
      --set PHOTOPRISM_ASSETS_PATH ${assets_path} \
      --set PHOTOPRISM_DARKTABLE_BIN ${darktable}/bin/darktable-cli \
      --set PHOTOPRISM_RAWTHERAPEE_BIN ${rawtherapee}/bin/rawtherapee-cli \
      --set PHOTOPRISM_HEIFCONVERT_BIN ${libheif}/bin/heif-dec \
      --set PHOTOPRISM_RSVGCONVERT_BIN ${librsvg}/bin/rsvg-convert \
      --set PHOTOPRISM_FFMPEG_BIN ${ffmpeg}/bin/ffmpeg \
      --set PHOTOPRISM_EXIFTOOL_BIN ${exiftool}/bin/exiftool \
      --set PHOTOPRISM_IMAGEMAGICK_BIN ${imagemagick}/bin/convert

    # install frontend
    ln -s ${frontend}/assets/* ${assets_path}
    rm ${assets_path}/models
    mkdir -p ${assets_path}/models
    ln -s ${frontend}/assets/models/* ${assets_path}/models/

    # install tensorflow models
    ln -s ${nasnet}/nasnet ${assets_path}/models/
    ln -s ${nsfw}/nsfw ${assets_path}/models/
    ln -s ${facenet}/facenet ${assets_path}/models/

    runHook postInstall
  '';

  dontBuild = true;
  dontUnpack = true;
  passthru.tests.photoprism = nixosTests.photoprism;
  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "Personal Photo Management powered by Go and Google TensorFlow";
    homepage = "https://photoprism.app";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ benesim ];
    mainProgram = "photoprism";
  };
})
