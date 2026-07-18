{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  boost,
  dbus,
  fzssh,
  gettext,
  gnutls,
  gtk3,
  libfilezilla,
  libidn,
  nettle,
  pkg-config,
  pugixml,
  sqlite,
  tinyxml,
  wrapGAppsHook3,
  wxwidgets_3_2,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "filezilla";
  version = "3.70.5";

  src = fetchurl {
    # Upstream download link was made unstable on purpose
    # See https://trac.filezilla-project.org/ticket/13186
    url = "https://sources.archlinux.org/other/filezilla/filezilla-${finalAttrs.version}.tar.xz";
    hash = "sha256-d8FsJfsdlNUSlLAe/SDT5cwRmESFfktDmCrKa4mO5dY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapGAppsHook3
    xdg-utils
  ];

  buildInputs = [
    boost
    dbus
    fzssh
    gettext
    gnutls
    libfilezilla
    libidn
    nettle
    pugixml
    sqlite
    tinyxml
    gtk3
  ];

  configureFlags = [
    "--disable-manualupdatecheck"
    "--disable-autoupdatecheck"
    "--with-wx-prefix=${wxwidgets_3_2}"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}"
    )
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Graphical FTP, FTPS and SFTP client";

    longDescription = ''
      FileZilla Client is a free, open source FTP client. It supports
      FTP, SFTP, and FTPS (FTP over SSL/TLS). The client is available
      under many platforms, binaries for Windows, Linux and macOS are
      provided.
    '';

    homepage = "https://filezilla-project.org/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      iedame
      pSub
    ];

    platforms = lib.platforms.linux;
  };
})
