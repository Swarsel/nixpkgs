{
  lib,
  stdenv,
  atk,
  buildFHSEnv,
  cairo,
  dpkg,
  gdk-pixbuf,
  glib,
  gtk2-x11,
  libx11,
  makeWrapper,
  pango,
}:

{
  src,
  toolName,
  version,
  ...
}@attrs:
let
  wrapBinary = libPaths: binaryName: ''
    wrapProgram "$out/bin/${binaryName}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libPaths}"
  '';
  pkg = stdenv.mkDerivation rec {
    inherit (attrs) version src;

    nativeBuildInputs = [
      makeWrapper
      dpkg
    ];

    installPhase =
      attrs.installPhase or ''
        mkdir -p "$out/bin"
        cp -a usr/* "$out/"
        ${(wrapBinary libs) attrs.toolName}
      '';

    dontBuild = true;

    libs =
      attrs.libs or [
        atk
        cairo
        gdk-pixbuf
        glib
        gtk2-x11
        pango
        libx11
      ];

    name = "${toolName}-${version}";

    unpackPhase =
      attrs.unpackPhase or ''
        dpkg-deb -x ${attrs.src} ./
      '';

    meta =

      {
        homepage = "http://bitscope.com/software/";
        license = lib.licenses.unfree;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
      }
      // (attrs.meta or { });
  };
in
buildFHSEnv {
  inherit (attrs) version;
  pname = attrs.toolName;
  runScript = "${pkg.outPath}/bin/${attrs.toolName}";
}
// {
  inherit (pkg) meta name;
}
