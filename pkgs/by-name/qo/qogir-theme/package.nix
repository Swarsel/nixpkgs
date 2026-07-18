{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  gitUpdater,
  gnome-themes-extra,
  gtk-engine-murrine,
  jdupes,
  librsvg,
  sassc,
  which,
  colorVariants ? [ ], # default: all
  themeVariants ? [ ], # default: blue
  tweaks ? [ ],
}:

let
  pname = "qogir-theme";

in
lib.checkListOfEnum "${pname}: theme variants" [ "default" "manjaro" "ubuntu" "all" ] themeVariants
  lib.checkListOfEnum
  "${pname}: color variants"
  [ "standard" "light" "dark" ]
  colorVariants
  lib.checkListOfEnum
  "${pname}: tweaks"
  [ "image" "square" "round" ]
  tweaks

  stdenv.mkDerivation
  rec {
    inherit pname;
    version = "2025-08-17";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "qogir-theme";
      rev = version;
      hash = "sha256-LS1BE2jR08/JW2+rixYhTmctAfK2yZVWIE4QnAX9PDQ=";
    };

    postPatch = ''
      patchShebangs install.sh clean-old-theme.sh
    '';

    nativeBuildInputs = [
      jdupes
      sassc
      which
    ];

    buildInputs = [
      gdk-pixbuf # pixbuf engine for Gtk2
      gnome-themes-extra # adwaita engine for Gtk2
      librsvg # pixbuf loader for svg
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes

      name= HOME="$TMPDIR" ./install.sh \
        ${lib.optionalString (themeVariants != [ ]) "--theme " + toString themeVariants} \
        ${lib.optionalString (colorVariants != [ ]) "--color " + toString colorVariants} \
        ${lib.optionalString (tweaks != [ ]) "--tweaks " + toString tweaks} \
        --dest $out/share/themes

      mkdir -p $out/share/doc/qogir-theme
      cp -a src/firefox $out/share/doc/qogir-theme

      rm $out/share/themes/*/{AUTHORS,COPYING}

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    propagatedUserEnvPkgs = [
      gtk-engine-murrine # murrine engine for Gtk2
    ];

    passthru.updateScript = gitUpdater { };

    meta = {
      description = "Flat Design theme for GTK based desktop environments";
      homepage = "https://github.com/vinceliuice/Qogir-theme";
      license = lib.licenses.gpl3Only;
      maintainers = [ lib.maintainers.romildo ];
      platforms = lib.platforms.unix;
    };
  }
