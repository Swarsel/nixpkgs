{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  glib,
  glib-networking,
  gobject-introspection,
  gst_all_1,
  gtk4,
  libadwaita,
  libsecret,
  libsoup_3,
  libspelling,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "dialect";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "dialect-app";
    repo = "dialect";
    tag = finalAttrs.version;
    hash = "sha256-Gy5KlcY22ykoWUzVk6w46SLndOmEQxMCcvo1ClMq0LM=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    libsoup_3
    glib-networking
    libadwaita
    libsecret
    libspelling
  ];

  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    patchShebangs --update --host $out/share/dialect/search_provider
  '';

  dependencies = with python3.pkgs; [
    dbus-python
    gtts
    pygobject3
    beautifulsoup4
  ];

  # Prevent double wrapping, let the Python wrapper use the args in preFixup.
  dontWrapGApps = true;
  pyproject = false; # built with meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Translation app for GNOME";
    homepage = "https://dialectapp.org";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "dialect";
    teams = [ lib.teams.gnome-circle ];
  };
})
