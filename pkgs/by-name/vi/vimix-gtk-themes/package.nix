{
  lib,
  fetchFromGitHub,
  gitUpdater,
  gnome-shell,
  gtk-engine-murrine,
  gtk_engines,
  jdupes,
  sassc,
  stdenvNoCC,
  colorVariants ? [ ], # default: all
  sizeVariants ? [ ], # default: standard
  themeVariants ? [ ], # default: doder (blue)
  tweaks ? [ ],
}:

lib.checkListOfEnum "vimix-gtk-themes: theme variants"
  [
    "doder"
    "beryl"
    "ruby"
    "amethyst"
    "jade"
    "grey"
    "all"
  ]
  themeVariants
  lib.checkListOfEnum
  "vimix-gtk-themes: color variants"
  [ "standard" "light" "dark" ]
  colorVariants
  lib.checkListOfEnum
  "vimix-gtk-themes: size variants"
  [ "standard" "compact" "all" ]
  sizeVariants
  lib.checkListOfEnum
  "vimix-gtk-themes: tweaks"
  [ "flat" "grey" "mix" "translucent" ]
  tweaks

  stdenvNoCC.mkDerivation
  rec {
    pname = "vimix-gtk-themes";
    version = "2025-06-20";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "vimix-gtk-themes";
      rev = version;
      sha256 = "uRm6v+Zag4FO7nFVcHhZjVhOfdOeYBZYQym0IBR8+HU=";
    };

    postPatch = ''
      patchShebangs install.sh
    '';

    nativeBuildInputs = [
      gnome-shell # needed to determine the gnome-shell version
      jdupes
      sassc
    ];

    buildInputs = [
      gtk_engines
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/themes
      name= HOME="$TMPDIR" ./install.sh \
        ${lib.optionalString (themeVariants != [ ]) "--theme " + toString themeVariants} \
        ${lib.optionalString (colorVariants != [ ]) "--color " + toString colorVariants} \
        ${lib.optionalString (sizeVariants != [ ]) "--size " + toString sizeVariants} \
        ${lib.optionalString (tweaks != [ ]) "--tweaks " + toString tweaks} \
        --dest $out/share/themes
      rm $out/share/themes/*/{AUTHORS,LICENSE}
      jdupes --quiet --link-soft --recurse $out/share
      runHook postInstall
    '';

    propagatedUserEnvPkgs = [
      gtk-engine-murrine
    ];

    passthru.updateScript = gitUpdater { };

    meta = {
      description = "Flat Material Design theme for GTK based desktop environments";
      homepage = "https://github.com/vinceliuice/vimix-gtk-themes";
      license = lib.licenses.gpl3Only;
      maintainers = [ lib.maintainers.romildo ];
      platforms = lib.platforms.unix;
    };
  }
