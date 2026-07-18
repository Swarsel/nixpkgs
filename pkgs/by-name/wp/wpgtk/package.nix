{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  gobject-introspection,
  gtk3,
  libxslt,
  python3Packages,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wpgtk";
  version = "6.7.1";

  src = fetchFromGitHub {
    owner = "deviantfero";
    repo = "wpgtk";
    tag = finalAttrs.version;
    hash = "sha256-TbykgmS/F/6N7ZmcKlX79RhMvOMBsfFNl8TZKLji80w=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
    writableTmpDirAsHomeHook # The $HOME variable must be set to build the package. A "permission denied" error will occur otherwise
  ];

  buildInputs = [
    gtk3
    adwaita-icon-theme
    libxslt
  ];

  # No test exist
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    pillow
    pywal16
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = true;
  # use pywal16 fork instead
  pythonRemoveDeps = [ "pywal" ];

  meta = {
    description = "Template based wallpaper/colorscheme generator and manager";

    longDescription = ''
      In short, wpgtk is a colorscheme/wallpaper manager with a template system attached which lets you create templates from any textfile and will replace keywords on it on the fly, allowing for great styling and theming possibilities.

      wpgtk uses pywal16 as its colorscheme generator, but builds upon it with a UI and other features, such as the abilty to mix and edit the colorschemes generated and save them with their respective wallpapers, having light and dark themes, hackable and fast GTK theme made specifically for wpgtk and custom keywords and values to replace in templates.

      INFO: To work properly, this tool needs "programs.dconf.enable = true" on nixos or dconf installed. A reboot may be required after installing dconf.
    '';

    homepage = "https://github.com/deviantfero/wpgtk";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      melkor333
      cafkafk
    ];

    platforms = lib.platforms.linux;
    mainProgram = "wpg";
  };
})
