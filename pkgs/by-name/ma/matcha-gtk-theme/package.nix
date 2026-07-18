{
  lib,
  fetchFromGitHub,
  gdk-pixbuf,
  gitUpdater,
  gtk-engine-murrine,
  jdupes,
  librsvg,
  stdenvNoCC,
  colorVariants ? [ ], # default: all
  themeVariants ? [ ], # default: blue
}:

let
  pname = "matcha-gtk-theme";

in
lib.checkListOfEnum "${pname}: color variants" [ "standard" "light" "dark" ] colorVariants
  lib.checkListOfEnum
  "${pname}: theme variants"
  [ "aliz" "azul" "sea" "pueril" "all" ]
  themeVariants

  stdenvNoCC.mkDerivation
  rec {
    inherit pname;
    version = "2025-04-11";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "matcha-gtk-theme";
      rev = version;
      sha256 = "sha256-vPAGEa3anWAynEg2AYme4qpHJdLDKk2CmL5iQ1mBYgM=";
    };

    postPatch = ''
      patchShebangs install.sh
    '';

    nativeBuildInputs = [
      jdupes
    ];

    buildInputs = [
      gdk-pixbuf
      librsvg
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes

      name= ./install.sh \
        ${lib.optionalString (colorVariants != [ ]) "--color " + toString colorVariants} \
        ${lib.optionalString (themeVariants != [ ]) "--theme " + toString themeVariants} \
        --dest $out/share/themes

      mkdir -p $out/share/doc/matcha-gtk-theme
      cp -a src/extra/firefox $out/share/doc/matcha-gtk-theme

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    propagatedUserEnvPkgs = [
      gtk-engine-murrine
    ];

    passthru.updateScript = gitUpdater { };

    meta = {
      description = "Stylish flat Design theme for GTK based desktop environments";
      homepage = "https://vinceliuice.github.io/theme-matcha";
      license = lib.licenses.gpl3Only;
      maintainers = [ lib.maintainers.romildo ];
      platforms = lib.platforms.unix;
    };
  }
