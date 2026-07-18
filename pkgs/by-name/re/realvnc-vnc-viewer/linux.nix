{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libx11,
  libxext,
  meta,
  pname,
  rpmextract,
  version,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src =
    {
      "x86_64-linux" = fetchurl rec {
        hash = "sha256-rIOP7d8qrOeMgaQRYo+GRXT1fLnPegdpONT0p5aBCxM=";
        name = "VNC-Viewer-${finalAttrs.version}-Linux-x64.rpm";
        url = "https://downloads.realvnc.com/download/file/viewer.files/${name}";
      };
    }
    .${stdenv.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  postPatch = ''
    substituteInPlace ./usr/share/applications/realvnc-vncviewer.desktop \
      --replace /usr/share/icons/hicolor/48x48/apps/vncviewer48x48.png vncviewer48x48.png
    substituteInPlace ./usr/share/mimelnk/application/realvnc-vncviewer-mime.desktop \
      --replace /usr/share/icons/hicolor/48x48/apps/vncviewer48x48.png vncviewer48x48.png
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    rpmextract
  ];

  buildInputs = [
    libx11
    libxext
    stdenv.cc.cc.libgcc or null
  ];

  installPhase = ''
    runHook preInstall

    mv usr $out

    runHook postInstall
  '';

  unpackPhase = ''
    rpmextract $src
  '';

  meta = meta // {
    mainProgram = "vncviewer";
  };
})
