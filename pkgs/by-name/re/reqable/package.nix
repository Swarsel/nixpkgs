{
  lib,
  stdenv,
  fetchurl,
  atk,
  autoPatchelfHook,
  cairo,
  dpkg,
  fontconfig,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  libdbusmenu,
  libdbusmenu-gtk3,
  libepoxy,
  libgcrypt,
  libgpg-error,
  lz4,
  nix-update-script,
  nspr,
  nss,
  pango,
  util-linux,
  wrapGAppsHook3,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "reqable";
  version = "3.2.3";

  src = fetchurl {
    url = "https://github.com/reqable/reqable-app/releases/download/${finalAttrs.version}/reqable-app-linux-x86_64.deb";
    hash = "sha256-C1nBAr/vrkMdqG6PyLWatdhom8u+IDUYvQCQd+genS4=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    atk
    cairo
    fontconfig
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    libdbusmenu
    libdbusmenu-gtk3
    libepoxy
    libgcrypt
    libgpg-error
    lz4
    nspr
    nss
    pango
    util-linux
    xz
  ];

  installPhase = ''
    runHook preInstall

    cp -r usr $out
    substituteInPlace $out/share/applications/reqable.desktop \
      --replace-fail "/usr/share/reqable/" ""

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper $out/share/reqable/reqable $out/bin/reqable \
      --prefix LD_LIBRARY_PATH : $out/share/reqable/lib \
      ''${gappsWrapperArgs[@]}

    rm -r $out/share/pixmaps
  '';

  dontWrapGApps = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Generation API debugging and testing one-stop solution";
    homepage = "https://reqable.com";
    changelog = "https://github.com/reqable/reqable-app/releases/tag/${finalAttrs.version}";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ chillcicada ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "reqable";
    downloadPage = "https://github.com/reqable/reqable-app/releases";
  };
})
