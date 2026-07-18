{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream,
  desktop-file-utils,
  feedbackd,
  glib,
  gmobile,
  gnome-desktop,
  gobject-introspection,
  gsound,
  gst_all_1,
  gtk4,
  json-glib,
  libadwaita,
  libportal,
  libportal-gtk4,
  libpulseaudio,
  libyaml,
  lm_sensors,
  meson,
  mobile-broadband-provider-info,
  modemmanager,
  ninja,
  nix-update-script,
  nixosTests,
  phoc,
  phosh,
  pkg-config,
  wayland-protocols,
  wayland-scanner,
  wrapGAppsHook4,
}:

let
  # Derived from subprojects/gvc.wrap
  gvc = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    hash = "sha256-10n441b7m/mvQRdrmEsxGxqjKUWzjGvnzJy256NZN5s=";
    owner = "guidog";
    repo = "libgnome-volume-control";
    rev = "d2442f455844e5292cb4a74ffc66ecc8d7595a9f";
  };
  # Derived from subprojects/glibcellbroadcast.wrap
  libcellbroadcast = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    hash = "sha256-rs9MoC54sVrs3HK0cbX4msYWA63y+DlDOZ5LboVtW9Y=";
    owner = "devrtz";
    repo = "cellbroadcastd";
    tag = "v0.0.2";
  };
  # Derived from subprojects/libcellbroadcast/subprojects/gvdb.wrap
  gvdb = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    hash = "sha256-4mqoHPlrMPenoGPwDqbtv4/rJ/uq9Skcm82pRvOxNIk=";
    owner = "GNOME";
    repo = "gvdb";
    rev = "4758f6fb7f889e074e13df3f914328f3eecb1fd3";
  };
in
stdenv.mkDerivation rec {
  pname = "phosh-mobile-settings";
  version = "0.54.0";

  src = fetchFromGitLab {
    owner = "Phosh";
    repo = "phosh-mobile-settings";
    rev = "v${version}";
    hash = "sha256-TuwxzzalNhNJwPmmPJmxsHebzksPYv8jV6K0vYntQIw=";
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    group = "World";
  };

  postPatch = ''
    ln -s ${gvc} subprojects/gvc
    ln -s ${libcellbroadcast} subprojects/libcellbroadcast
    ln -s ${gvdb} subprojects/gvdb
  '';

  nativeBuildInputs = [
    meson
    ninja
    phosh
    pkg-config
    wayland-scanner
    wrapGAppsHook4
    glib.dev
    gobject-introspection
    appstream
  ];

  buildInputs = [
    desktop-file-utils
    feedbackd
    gtk4
    libadwaita
    lm_sensors
    phoc
    wayland-protocols
    json-glib
    gsound
    gmobile
    gnome-desktop
    libpulseaudio
    libportal
    libportal-gtk4
    libyaml
    mobile-broadband-provider-info
    modemmanager
    gst_all_1.gst-plugins-base
  ];

  postInstall = ''
    # this is optional, but without it phosh-mobile-settings won't know about lock screen plugins
    ln -s '${phosh}/lib/phosh' "$out/lib/phosh"
    glib-compile-schemas "$out/share/glib-2.0/schemas"
  '';

  passthru = {
    tests.phosh = nixosTests.phosh;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Settings app for mobile specific things";
    homepage = "https://gitlab.gnome.org/World/Phosh/phosh-mobile-settings";
    changelog = "https://gitlab.gnome.org/World/Phosh/phosh-mobile-settings/-/blob/v${version}/debian/changelog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      rvl
      armelclo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "phosh-mobile-settings";
  };
}
