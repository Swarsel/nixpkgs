{
  lib,
  stdenv,
  fetchFromGitHub,
  cinnamon,
  glib,
  gnome-shell,
  gnome-themes-extra,
  gtk-engine-murrine,
  inkscape,
  makeFontsConf,
  meson,
  ninja,
  python3,
  sassc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "arc-theme";
  version = "20221218";

  src = fetchFromGitHub {
    owner = "jnsh";
    repo = "arc-theme";
    tag = finalAttrs.version;
    hash = "sha256-7VmqsUCeG5GwmrVdt9BJj0eZ/1v+no/05KwGFb7E9ns=";
  };

  postPatch = ''
    patchShebangs meson/install-file.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    sassc
    inkscape
    glib # for glib-compile-resources
    python3
  ];

  mesonFlags = [
    # "-Dthemes=cinnamon,gnome-shell,gtk2,gtk3,plank,xfwm,metacity"
    # "-Dvariants=light,darker,dark,lighter"
    "-Dcinnamon_version=${cinnamon.version}"
    "-Dgnome_shell_version=${gnome-shell.version}"
    # You will need to patch gdm to make use of this.
    "-Dgnome_shell_gresource=true"
  ];

  # Fontconfig error: Cannot load default config file: No such file: (null)
  env.FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ ]; };

  preBuild = ''
    # Shut up inkscape's warnings about creating profile directory
    export HOME="$TMPDIR"
  '';

  propagatedUserEnvPkgs = [
    gnome-themes-extra
    gtk-engine-murrine
  ];

  meta = {
    description = "Flat theme with transparent elements for GTK 3, GTK 2 and Gnome Shell";
    homepage = "https://github.com/jnsh/arc-theme";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      simonvandel
      romildo
    ];

    platforms = lib.platforms.linux;
  };
})
