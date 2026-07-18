{ stdenv, collectd }:

stdenv.mkDerivation {
  inherit (collectd) meta src version;
  pname = "collectd-data";

  installPhase = ''
    install -Dm444 -t $out/share/collectd/ src/*.{db,conf}
  '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
}
