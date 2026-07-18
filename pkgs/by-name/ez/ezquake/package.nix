{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  curlMinimal,
  expat,
  jansson,
  libGL,
  libjpeg,
  libpng,
  libsndfile,
  libx11,
  minizip,
  nix-update-script,
  pcre2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ezquake";
  version = "3.6.9";

  src = fetchFromGitHub {
    owner = "QW-Group";
    repo = "ezquake-source";
    tag = finalAttrs.version;
    hash = "sha256-AJe7ZvF88gKrW6IsTLpYI7RmzetFGZifntHzX7aNcG4=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/fs.h \
      --replace-fail '"unzip.h"' '<minizip/unzip.h>'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    SDL2
    curlMinimal
    expat
    jansson
    libGL
    libx11
    libjpeg
    libpng
    libsndfile
    minizip
    pcre2
  ];

  installPhase =
    let
      sys = lib.last (lib.splitString "-" stdenv.hostPlatform.system);
      arch = lib.head (lib.splitString "-" stdenv.hostPlatform.system);
    in
    ''
      runHook preInstall

      install -D \
        ezquake-${sys}-${arch} $out/bin/${finalAttrs.meta.mainProgram}

      runHook postInstall
    '';

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern QuakeWorld client focused on competitive online play";
    homepage = "https://ezquake.com/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ edwtjo ];
    platforms = lib.platforms.linux;
    mainProgram = "ezquake";
  };
})
