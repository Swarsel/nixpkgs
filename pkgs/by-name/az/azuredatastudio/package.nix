{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  copyDesktopItems,
  cups,
  curl,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gnutar,
  gtk3,
  icu,
  libdrm,
  libgbm,
  libunwind,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxshmfence,
  makeDesktopItem,
  makeWrapper,
  nspr,
  nss,
  openssl,
  pango,
  systemd,
  wrapGAppsHook3,
  zlib,
}:

# from justinwoo/azuredatastudio-nix
# https://github.com/justinwoo/azuredatastudio-nix/blob/537c48aa3981cd1a82d5d6e508ab7e7393b3d7c8/default.nix

let
  desktopItem = makeDesktopItem {
    actions.new-empty-window = {
      exec = "azuredatastudio --no-sandbox --new-window %F";
      icon = "azuredatastudio";
      name = "New Empty Window";
    };

    categories = [
      "Utility"
      "TextEditor"
      "Development"
      "IDE"
    ];

    comment = "Data Management Tool that enables you to work with SQL Server, Azure SQL DB and SQL DW from Windows, macOS and Linux.";
    desktopName = "Azure Data Studio";
    exec = "azuredatastudio --no-sandbox --unity-launch %F";
    genericName = "Text Editor";
    icon = "azuredatastudio";
    keywords = [ "azuredatastudio" ];

    mimeTypes = [
      "text/plain"
      "inode/directory"
      "application/x-azuredatastudio-workspace"
    ];

    name = "azuredatastudio";
    startupNotify = true;
    startupWMClass = "azuredatastudio";
  };

  urlHandlerDesktopItem = makeDesktopItem {
    categories = [
      "Utility"
      "TextEditor"
      "Development"
      "IDE"
    ];

    comment = "Azure Data Studio";
    desktopName = "Azure Data Studio - URL Handler";
    exec = "azuredatastudio --no-sandbox --open-url %U";
    genericName = "Text Editor";
    icon = "azuredatastudio";
    keywords = [ "azuredatastudio" ];
    mimeTypes = [ "x-scheme-handler/azuredatastudio" ];
    name = "azuredatastudio-url-handler";
    noDisplay = true;
    startupNotify = true;
    startupWMClass = "azuredatastudio";
  };
in
stdenv.mkDerivation rec {

  pname = "azuredatastudio";
  version = "1.49.1";

  src = fetchurl {
    # Url can be found at: https://github.com/microsoft/azuredatastudio/releases
    # In the downloads table for Linux .tar.gz
    # This will give a go.microsoft redirect link, I think it's better to use the direct link to which the redirect points.
    # You can do so by using curl: curl -I <go.microsoft link>
    url = "https://download.microsoft.com/download/7/8/3/783c2037-8607-43c4-a593-0936e965d38b/azuredatastudio-linux-1.49.1.tar.gz";
    sha256 = "sha256-0LCrRUTTe8UEDgtGLvxVQL8pA5dwA6SvZEZSDILr7jo=";
    name = "${pname}-${version}.tar.gz";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = [
    libuuid
    at-spi2-core
    at-spi2-atk
  ];

  installPhase = ''
    runHook preInstall

    install -D ${targetPath}/resources/app/resources/linux/code.png $out/share/icons/azuredatastudio.png

    runHook postInstall
  '';

  preFixup = ''
    fix_sqltoolsservice()
    {
      mv ${sqltoolsservicePath}/$1 ${sqltoolsservicePath}/$1_old
      patchelf \
        --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        ${sqltoolsservicePath}/$1_old

      makeWrapper \
        ${sqltoolsservicePath}/$1_old \
        ${sqltoolsservicePath}/$1 \
        --set LD_LIBRARY_PATH ${sqltoolsserviceRpath}
    }

    fix_sqltoolsservice MicrosoftSqlToolsServiceLayer
    fix_sqltoolsservice MicrosoftSqlToolsCredentials
    fix_sqltoolsservice SqlToolsResourceProviderService

    patchelf \
      --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
      ${targetPath}/${edition}

    mkdir -p $out/bin
    makeWrapper \
      ${targetPath}/bin/${edition} \
      $out/bin/azuredatastudio \
      --set LD_LIBRARY_PATH ${rpath}
  '';

  desktopItems = [
    desktopItem
    urlHandlerDesktopItem
  ];

  # change this to azuredatastudio-insiders for insiders releases
  edition = "azuredatastudio";

  rpath = lib.concatStringsSep ":" [
    (lib.makeLibraryPath [
      alsa-lib
      at-spi2-atk
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libgbm
      nss
      nspr
      libdrm
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxshmfence
      libxkbcommon
      libxkbfile
      pango
      stdenv.cc.cc
      systemd
    ])
    targetPath
    sqltoolsserviceRpath
  ];

  # this will most likely need to be updated when azuredatastudio's version changes
  sqltoolsservicePath = "${targetPath}/resources/app/extensions/mssql/sqltoolsservice/Linux/5.0.20240724.1";

  sqltoolsserviceRpath = lib.makeLibraryPath [
    stdenv.cc.cc
    libunwind
    libuuid
    icu
    openssl
    zlib
    curl
  ];

  targetPath = "$out/${edition}";

  unpackPhase = ''
    mkdir -p ${targetPath}
    ${gnutar}/bin/tar xf $src --strip 1 -C ${targetPath}
  '';

  meta = {
    description = "Data management tool that enables working with SQL Server, Azure SQL DB and SQL DW";
    homepage = "https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ xavierzwirtz ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "azuredatastudio";
  };
}
