{
  lib,
  stdenv,
  fetchurl,
  bash,
  wget,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wgetpaste";
  version = "2.34";

  src = fetchurl {
    url = "https://github.com/zlin/wgetpaste/releases/download/${finalAttrs.version}/wgetpaste-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-vW0G7ZAaPWPJyMVxJghP8JlPCZAb+xY4uHlT6sHpQz8=";
  };

  installPhase = ''
    mkdir -p $out/bin;
    cp wgetpaste $out/bin;
  '';

  # currently zsh-autocompletion support is not installed
  prePatch = ''
    substituteInPlace wgetpaste --replace "/usr/bin/env bash" "${bash}/bin/bash"
    substituteInPlace wgetpaste --replace "LC_ALL=C wget" "LC_ALL=C ${wget}/bin/wget"
  '';

  meta = {
    description = "Command-line interface to various pastebins";
    homepage = "https://github.com/zlin/wgetpaste";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      qknight
    ];

    platforms = lib.platforms.all;
    mainProgram = "wgetpaste";
  };
})
