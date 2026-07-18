{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  appstream-glib,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  gcr_4,
  glib,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk-vnc,
  gtk4,
  libGL,
  libadwaita,
  libepoxy,
  libvirt,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  spice-gtk,
  spice-protocol,
  usbredir,
  vte-gtk4,
  wrapGAppsHook4,
  xdg-desktop-portal,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "field-monitor";
  version = "50.1";

  src = fetchFromGitHub {
    owner = "theCapypara";
    repo = "field-monitor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-waMa70oLKvIoljvE+MjWWKVL1Cd0xnasVeB17tfMQW8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    appstream
    appstream-glib
    blueprint-compiler
    cargo
    desktop-file-utils
    libxml2
    meson
    ninja
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    gcr_4
    glib
    gsettings-desktop-schemas
    gtk-vnc
    gtk4
    libadwaita
    libepoxy
    libGL
    libvirt
    openssl
    spice-gtk
    spice-protocol
    usbredir
    vte-gtk4
    xdg-desktop-portal
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ]);

  postInstall = ''
    wrapProgram $out/bin/de.capypara.FieldMonitor --prefix PATH ':' "$out/libexec"
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-fsrczFhoIilxgZRH2PVXC67YdkMsIjA6zTfix57TTzo=";
  };

  mesonBuildType = "release";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Viewer for virtual machines and other external screens";
    homepage = "https://github.com/theCapypara/field-monitor";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ theCapypara ];
    platforms = lib.platforms.linux;
    mainProgram = "de.capypara.FieldMonitor";
  };
})
