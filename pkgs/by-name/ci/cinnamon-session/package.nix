{
  lib,
  stdenv,
  fetchFromGitHub,
  cinnamon-desktop,
  cinnamon-settings-daemon,
  cinnamon-translations,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  libcanberra,
  libexecinfo,
  libx11,
  libxau,
  libxcomposite,
  libxext,
  libxrender,
  libxslt,
  libxtst,
  meson,
  ninja,
  pango,
  pkg-config,
  python3,
  systemd,
  wrapGAppsHook3,
  xapp,
  xtrans,
}:

let
  pythonEnv = python3.withPackages (
    pp: with pp; [
      python-xapp
      pygobject3
      setproctitle
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cinnamon-session";
  version = "6.6.4";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "cinnamon-session";
    tag = finalAttrs.version;
    hash = "sha256-rx7+tBXQ9kvnRYNxgF1QXyhk9NamUIjti/6GGrACYU0=";
  };

  postPatch = ''
    # patchShebangs requires executable file
    chmod +x data/meson_install_schemas.py
    patchShebangs data/meson_install_schemas.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    wrapGAppsHook3
    libexecinfo
    python3
    pkg-config
    libxslt
  ];

  buildInputs = [
    # meson.build
    cinnamon-desktop
    gtk3
    glib
    libcanberra
    pango
    libx11
    libxext
    xapp
    libxau
    libxcomposite

    systemd

    libxtst
    libxrender
    xtrans

    # other (not meson.build)
    cinnamon-settings-daemon
    gsettings-desktop-schemas
    pythonEnv # for cinnamon-session-quit
  ];

  mesonFlags = [
    # use locales from cinnamon-translations
    "--localedir=${cinnamon-translations}/share/locale"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${cinnamon-desktop}/share"
      --prefix XDG_CONFIG_DIRS : "${cinnamon-settings-daemon}/etc/xdg"
    )
  '';

  meta = {
    description = "Cinnamon session manager";
    homepage = "https://github.com/linuxmint/cinnamon-session";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
