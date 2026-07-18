{
  stdenv,
  libayatana-appindicator,
}:

{ src, version, ... }:

stdenv.mkDerivation rec {
  inherit version src;
  inherit (src) passthru;
  pname = "system-tray";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r '${src}'/* "$out"
    substituteInPlace "$out/linux/tray.cc" \
      --replace "libappindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    runHook postInstall
  '';
}
