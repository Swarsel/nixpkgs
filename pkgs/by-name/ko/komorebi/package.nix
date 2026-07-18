{
  lib,
  stdenv,
  fetchFromGitHub,
  clutter-gst,
  clutter-gtk,
  glib,
  gtk3,
  libgee,
  meson,
  ninja,
  pkg-config,
  testers,
  vala,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "komorebi";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "Komorebi-Fork";
    repo = "komorebi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vER69dSxu4JuWNAADpkxHE/zjOMhQp+Fc21J+JHQ8xk=";
  };

  postPatch = ''
    substituteInPlace meson.build --replace-fail "webkit2gtk-4.0" "webkit2gtk-4.1"
  '';

  nativeBuildInputs = [
    meson
    vala
    pkg-config
    ninja
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libgee
    webkitgtk_4_1
    clutter-gtk
    clutter-gst
  ];

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "Beautiful and customizable wallpaper manager for Linux";
    homepage = "https://github.com/Komorebi-Fork/komorebi";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
