{
  lib,
  stdenv,
  fetchFromGitLab,
  # The themes here are soft dependencies; only icons are missing without them.
  adwaita-icon-theme,
  at-spi2-core,
  cmake,
  curl,
  desktopToDarwinBundle,
  freerdp,
  fuse3,
  gettext,
  glib,
  gnutls,
  gsettings-desktop-schemas,
  gtk3,
  harfbuzz,
  json-glib,
  libappindicator-gtk3,
  libdbusmenu-gtk3,
  libepoxy,
  libgcrypt,
  libpthread-stubs,
  libsecret,
  libsodium,
  libsoup_3,
  libssh,
  libvncserver,
  libx11,
  libxdmcp,
  libxkbcommon,
  libxkbfile,
  ninja,
  openssl,
  pcre2,
  pkg-config,
  python3,
  spice-gtk,
  spice-protocol,
  vte,
  wayland,
  webkitgtk_4_1,
  wrapGAppsHook3,
  withLibsecret ? stdenv.hostPlatform.isLinux,
  withVte ? true,
  withWebkitGtk ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "remmina";
  version = "1.4.43";

  src = fetchFromGitLab {
    owner = "Remmina";
    repo = "Remmina";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7nY2NhlWp+4FTTmeam1B+sotqis0lSwhozSC8I14aMI=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  buildInputs = [
    curl
    gsettings-desktop-schemas
    glib
    gtk3
    gettext
    libxkbfile
    libx11
    freerdp
    libssh
    libgcrypt
    gnutls
    pcre2
    libvncserver
    libpthread-stubs
    libxdmcp
    libxkbcommon
    libsoup_3
    spice-protocol
    spice-gtk
    libepoxy
    at-spi2-core
    openssl
    adwaita-icon-theme
    json-glib
    libsodium
    harfbuzz
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    fuse3
    libappindicator-gtk3
    libdbusmenu-gtk3
    wayland
  ]
  ++ lib.optionals withLibsecret [ libsecret ]
  ++ lib.optionals withWebkitGtk [ webkitgtk_4_1 ]
  ++ lib.optionals withVte [ vte ];

  cmakeFlags = [
    "-DWITH_FREERDP3=ON"
    "-DWITH_VTE=${if withVte then "ON" else "OFF"}"
    "-DWITH_TELEPATHY=OFF"
    "-DWITH_AVAHI=OFF"
    "-DWITH_LIBSECRET=${if withLibsecret then "ON" else "OFF"}"
    "-DWITH_WEBKIT2GTK=${if withWebkitGtk then "ON" else "OFF"}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-DHAVE_LIBAPPINDICATOR=OFF"
    "-DWITH_CUPS=OFF"
    "-DWITH_ICON_CACHE=OFF"
    # Don't use system installed Python like on GitHub Actions runners
    "-DPYTHON_INCLUDE_DIR=${python3}/include/${python3.libPrefix}"
    "-DPYTHON_LIBRARY=${python3}/lib/libpython${python3.pythonVersion}${stdenv.hostPlatform.extensions.sharedLibrary}"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  preFixup = ''
    gappsWrapperArgs+=(
      --set-default SSL_CERT_DIR "/etc/ssl/certs/"
      --prefix LD_LIBRARY_PATH : "${libx11.out}/lib"
      ${lib.optionalString stdenv.hostPlatform.isDarwin ''
        --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
      ''}
      --prefix PATH : "${lib.makeBinPath [ python3 ]}"
    )
  '';

  dontWrapQtApps = true;

  meta = {
    description = "Remote desktop client written in GTK";
    homepage = "https://gitlab.com/Remmina/Remmina";

    changelog = "https://gitlab.com/Remmina/Remmina/-/blob/master/CHANGELOG.md#${
      lib.replaceStrings [ "." ] [ "" ] finalAttrs.src.rev
    }";

    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      bbigras
      melsigl
      ryantm
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "remmina";
  };
})
