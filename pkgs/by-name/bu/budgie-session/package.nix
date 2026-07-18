{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  bash,
  dbus,
  docbook_xml_dtd_412,
  docbook_xsl,
  gettext,
  glib,
  gnome-desktop,
  gnome-settings-daemon,
  gsettings-desktop-schemas,
  gtk3,
  json-glib,
  libepoxy,
  libice,
  libxslt,
  makeWrapper,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  replaceVars,
  systemd,
  xmlto,
  xtrans,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "budgie-session";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "budgie-session";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MqFZ/0Xe2EXVzbhviNSO3gbZK8R+wLGQOoVkJDA6/Eg=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    (replaceVars ./fix-paths.patch {
      bash = lib.getExe bash;
      dbusLaunch = lib.getExe' dbus "dbus-launch";
      gsettings = lib.getExe' glib "gsettings";
    })
  ];

  postPatch = ''
    chmod +x meson_post_install.py # patchShebangs requires executable file
    patchShebangs meson_post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    makeWrapper
    xmlto
    libxslt
    docbook_xsl
    docbook_xml_dtd_412
    python3
    dbus # for DTD
  ];

  buildInputs = [
    glib
    gtk3
    libice
    gnome-desktop
    json-glib
    xtrans
    adwaita-icon-theme
    gnome-settings-daemon
    gsettings-desktop-schemas
    systemd
    libepoxy
  ];

  # `bin/budgie-session` will reset the environment when run in wayland, we
  # therefor wrap `libexec/budgie-session-binary` instead which is the actual
  # binary needing wrapping
  preFixup = ''
    wrapProgram "$out/libexec/budgie-session-binary" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --suffix XDG_DATA_DIRS : "$out/share:$GSETTINGS_SCHEMAS_PATH" \
      --suffix XDG_CONFIG_DIRS : "${gnome-settings-daemon}/etc/xdg"
  '';

  separateDebugInfo = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Session manager for Budgie";
    homepage = "https://github.com/BuddiesOfBudgie/budgie-session";
    changelog = "https://github.com/BuddiesOfBudgie/budgie-session/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.budgie ];
  };
})
