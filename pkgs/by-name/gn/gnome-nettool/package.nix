{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  dnsutils,
  fetchpatch,
  glib,
  gnome,
  gtk3,
  inetutils,
  iputils,
  itstool,
  libgtop,
  meson,
  ninja,
  nmap,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-nettool";
  version = "42.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-nettool/${lib.versions.major finalAttrs.version}/gnome-nettool-${finalAttrs.version}.tar.xz";
    hash = "sha256-pU8p7vIDiu5pVRyLGcpPdY5eueIJCkvGtWM9/wGIdR8=";
  };

  patches = [
    # Fix build with meson 0.61
    # https://gitlab.gnome.org/GNOME/gnome-nettool/-/merge_requests/3
    (fetchpatch {
      hash = "sha256-fbpfL8Xb1GsadpQzAdmu8FSPs++bsGCVdcwnzQWttGY=";
      url = "https://gitlab.gnome.org/GNOME/gnome-nettool/-/commit/1124c3e1fdb8472d30b7636500229aa16cdc1244.patch";
    })
  ];

  postPatch = ''
    chmod +x postinstall.py
    patchShebangs postinstall.py
  '';

  nativeBuildInputs = [
    desktop-file-utils
    itstool
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libgtop
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${
        lib.makeBinPath [
          dnsutils # for dig
          iputils # for ping
          nmap # for nmap
          inetutils # for ping6, traceroute, whois
        ]
      }"
    )
  '';

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-nettool"; };
  };

  meta = {
    description = "Collection of networking tools";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-nettool";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-nettool";
    teams = [ lib.teams.gnome ];
  };
})
