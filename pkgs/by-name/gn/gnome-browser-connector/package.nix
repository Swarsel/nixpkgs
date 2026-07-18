{
  lib,
  fetchurl,
  gnome,
  gnome-shell,
  gobject-introspection,
  meson,
  ninja,
  python3,
  wrapGAppsNoGuiHook,
}:

let
  inherit (python3.pkgs) buildPythonApplication pygobject3;
in
buildPythonApplication (finalAttrs: {
  pname = "gnome-browser-connector";
  version = "42.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-browser-connector/${lib.versions.major finalAttrs.version}/gnome-browser-connector-${finalAttrs.version}.tar.xz";
    sha256 = "vZcCzhwWNgbKMrjBPR87pugrJHz4eqxgYQtBHfFVYhI=";
  };

  postPatch = ''
    patchShebangs contrib/merge_json.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    wrapGAppsNoGuiHook
    gobject-introspection # for setup-hook
  ];

  buildInputs = [
    gnome-shell
  ];

  # Arguments to be passed to `makeWrapper`, only used by buildPython*
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  pythonPath = [
    pygobject3
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-browser-connector";
    };
  };

  meta = {
    description = "Native host connector for the GNOME Shell browser extension";

    longDescription = ''
      To use the integration, install the [browser extension](https://gitlab.gnome.org/GNOME/gnome-browser-extension), and then set `services.gnome.gnome-browser-connector.enable` to `true`.
    '';

    homepage = "https://gitlab.gnome.org/GNOME/gnome-browser-connector";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})
