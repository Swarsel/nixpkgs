{
  lib,
  fetchurl,
  mkKdeDerivation,
  pkg-config,
  pulseaudio,
}:
mkKdeDerivation rec {
  pname = "pulseaudio-qt";
  version = "1.8.1";

  src = fetchurl {
    url = "mirror://kde/stable/pulseaudio-qt/pulseaudio-qt-${version}.tar.xz";
    hash = "sha256-eWGcVblICKp9MH+yNK05oQltCI8h+Aa+DniL55p2s8k=";
  };

  extraBuildInputs = [ pulseaudio ];
  extraNativeBuildInputs = [ pkg-config ];

  meta.license = with lib.licenses; [
    lgpl21Only
    lgpl3Only
  ];
}
