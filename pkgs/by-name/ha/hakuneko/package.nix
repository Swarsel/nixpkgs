{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  dpkg,
  libxscrnsaver,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  nspr,
  nss,
  systemd,
  udev,
  wrapGAppsHook3,
}:
let
  desktopItem = makeDesktopItem {
    categories = [
      "Network"
      "FileTransfer"
    ];

    desktopName = "HakuNeko Desktop";
    exec = "hakuneko";
    genericName = "Manga & Anime Downloader";
    icon = "hakuneko-desktop";
    name = "hakuneko-desktop";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hakuneko";
  version = "6.1.7";

  src =
    {
      "i686-linux" = fetchurl {
        sha256 = "32017d26bafffaaf0a83dd6954d3926557014af4022a972371169c56c0e3d98b";
        url = "https://github.com/manga-download/hakuneko/releases/download/v${finalAttrs.version}/hakuneko-desktop_${finalAttrs.version}_linux_i386.deb";
      };

      "x86_64-linux" = fetchurl {
        sha256 = "06bb17d7a06bb0601053eaaf423f9176f06ff3636cc43ffc024438e1962dcd02";
        url = "https://github.com/manga-download/hakuneko/releases/download/v${finalAttrs.version}/hakuneko-desktop_${finalAttrs.version}_linux_amd64.deb";
      };
    }
    ."${stdenv.hostPlatform.system}" or (throw "unsupported system ${stdenv.hostPlatform.system}");

  # TODO: migrate off autoPatchelfHook and use nixpkgs' electron
  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    nss
    nspr
    libxscrnsaver
    libxtst
    systemd
  ];

  installPhase = ''
    cp -R usr "$out"
    # Overwrite existing .desktop file.
    cp "${desktopItem}/share/applications/hakuneko-desktop.desktop" \
       "$out/share/applications/hakuneko-desktop.desktop"
  '';

  postFixup = ''
    makeWrapper $out/lib/hakuneko-desktop/hakuneko $out/bin/hakuneko \
      "''${gappsWrapperArgs[@]}"
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;
  dontWrapGApps = true;

  runtimeDependencies = [
    (lib.getLib udev)
  ];

  unpackPhase = ''
    # The deb file contains a setuid binary, so 'dpkg -x' doesn't work here
    dpkg --fsys-tarfile $src | tar --extract
  '';

  meta = {
    description = "Manga & Anime Downloader";
    homepage = "https://sourceforge.net/projects/hakuneko/";
    license = lib.licenses.unlicense;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      nloomans
    ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "hakuneko";
  };
})
