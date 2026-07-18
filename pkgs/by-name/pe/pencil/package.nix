{
  lib,
  stdenv,
  fetchurl,
  # build dependencies
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  glibc,
  gtk3,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  makeWrapper,
  nspr,
  nss,
  pango,
  systemd,
  wrapGAppsHook3,
}:
let

  deps = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    glibc
    gtk3
    libuuid
    nspr
    nss
    pango
    libx11
    libxcb
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    (lib.getLib stdenv.cc.cc)
    stdenv.cc.cc
  ];

in
stdenv.mkDerivation (finalAttrs: {
  pname = "pencil";
  version = "3.1.0";

  src = fetchurl {
    url = "https://pencil.evolus.vn/dl/V${finalAttrs.version}.ga/pencil_${finalAttrs.version}.ga_amd64.deb";
    sha256 = "01ae54b1a1351b909eb2366c6ec00816e1deba370e58f35601cf7368f10aaba3";
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = deps;

  installPhase = ''
    mkdir -p $out/bin $out/opt $out/share/applications
    cp -R usr/share $out/
    cp -R opt/pencil*/ $out/opt/pencil
    cp $out/opt/pencil/pencil.desktop $out/share/applications/

    # fix the path in the desktop file
    substituteInPlace \
      $out/share/applications/pencil.desktop \
      --replace /opt/ $out/opt/

    # symlink the binary to bin/
    ln -s $out/opt/pencil/pencil $out/bin/pencil
  '';

  preFixup =
    let
      packages = deps;
      libPathNative = lib.makeLibraryPath packages;
      libPath64 = lib.makeSearchPathOutput "lib" "lib64" packages;
      libPath = "${libPathNative}:${libPath64}";
    in
    ''
      # patch executable
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}:$out/opt/pencil" \
        $out/opt/pencil/pencil

      # fix missing libudev
      ln -s ${lib.getLib systemd}/lib/libudev.so.1 $out/opt/pencil/libudev.so.1
      wrapProgram $out/opt/pencil/pencil \
        --prefix LD_LIBRARY_PATH : $out/opt/pencil
    '';

  dontBuild = true;
  sourceRoot = ".";

  unpackCmd = ''
    ar p "$src" data.tar.gz | tar xz
  '';

  meta = {
    description = "GUI prototyping/mockup tool";
    homepage = "https://pencil.evolus.vn/";
    license = lib.licenses.gpl2; # Commercial license is also available
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      bjornfor
      prikhi
      mrVanDalo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pencil";
  };
})
