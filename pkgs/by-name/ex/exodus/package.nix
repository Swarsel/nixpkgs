{
  lib,
  stdenv,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  gdk-pixbuf,
  glib,
  gtk3-x11,
  libgbm,
  libpulseaudio,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  nspr,
  nss,
  pango,
  requireFile,
  systemd,
  unzip,
  util-linux,
  vivaldi-ffmpeg-codecs,
  xorg_sys_opengl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "exodus";
  version = "26.1.5";

  src = requireFile {
    url = "https://downloads.exodus.com/releases/exodus-linux-x64-${finalAttrs.version}.zip";
    hash = "sha256-BClWuL4dTc1lESyEXuDtpGp1K/AxICbpQIaWYLrme1M=";
    name = "exodus-linux-x64-${finalAttrs.version}.zip";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    cp -r . $out
    ln -s $out/Exodus $out/bin/Exodus
    ln -s $out/bin/Exodus $out/bin/exodus
    ln -s $out/exodus.desktop $out/share/applications
    substituteInPlace $out/share/applications/exodus.desktop \
          --replace-fail 'Exec=bash -c "cd \\`dirname %k\\` && ./Exodus %u"' "Exec=Exodus %u"
  '';

  preFixup =
    let
      libPath = lib.makeLibraryPath [
        glib
        nss
        nspr
        gtk3-x11
        pango
        atk
        cairo
        gdk-pixbuf
        libx11
        libxcb
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxrender
        libxshmfence
        libxtst
        xorg_sys_opengl
        util-linux
        libxrandr
        libxscrnsaver
        alsa-lib
        dbus.lib
        at-spi2-atk
        at-spi2-core
        cups.lib
        libpulseaudio
        systemd
        vivaldi-ffmpeg-codecs
        libxkbcommon
        libgbm
      ];
    in
    ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/Exodus
    '';

  dontBuild = true;
  dontPatchELF = true;

  meta = {
    description = "Top-rated cryptocurrency wallet with Trezor integration and built-in Exchange";
    homepage = "https://www.exodus.io/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      mmahut
      rople380
      Crafter
    ];

    platforms = lib.platforms.linux;
  };
})
