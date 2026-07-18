{
  lib,
  fetchFromGitHub,
  gitUpdater,
  gtk-engine-murrine,
  jdupes,
  sassc,
  stdenvNoCC,
  colorVariants ? [ ], # default: all
  sizeVariants ? [ ], # default: standard
  themeVariants ? [ ], # default: blue
  tweaks ? [ ],
}:

let
  pname = "fluent-gtk-theme";
in
lib.checkListOfEnum "${pname}: theme variants"
  [
    "default"
    "purple"
    "pink"
    "red"
    "orange"
    "yellow"
    "green"
    "teal"
    "grey"
    "all"
  ]
  themeVariants
  lib.checkListOfEnum
  "${pname}: color variants"
  [
    "standard"
    "light"
    "dark"
  ]
  colorVariants
  lib.checkListOfEnum
  "${pname}: size variants"
  [
    "standard"
    "compact"
  ]
  sizeVariants
  lib.checkListOfEnum
  "${pname}: tweaks"
  [
    "solid"
    "float"
    "round"
    "blur"
    "noborder"
    "square"
  ]
  tweaks

  stdenvNoCC.mkDerivation
  (finalAttrs: {
    inherit pname;
    version = "2025-04-17";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "fluent-gtk-theme";
      rev = finalAttrs.version;
      hash = "sha256-AaFj9lG9lWg0a0ksJ0ufoUpsunR3uDhcdb7oSrvAmPI=";
    };

    postPatch = ''
      patchShebangs install.sh
    '';

    nativeBuildInputs = [
      jdupes
      sassc
    ];

    installPhase = ''
      runHook preInstall

      name= HOME="$TMPDIR" ./install.sh \
        ${lib.optionalString (themeVariants != [ ]) "--theme " + toString themeVariants} \
        ${lib.optionalString (colorVariants != [ ]) "--color " + toString colorVariants} \
        ${lib.optionalString (sizeVariants != [ ]) "--size " + toString sizeVariants} \
        ${lib.optionalString (tweaks != [ ]) "--tweaks " + toString tweaks} \
        --icon nixos \
        --dest $out/share/themes

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    propagatedUserEnvPkgs = [ gtk-engine-murrine ];
    passthru.updateScript = gitUpdater { };

    meta = {
      description = "Fluent design gtk theme";
      homepage = "https://github.com/vinceliuice/Fluent-gtk-theme";
      changelog = "https://github.com/vinceliuice/Fluent-gtk-theme/releases/tag/${finalAttrs.version}";
      license = lib.licenses.gpl3Only;

      maintainers = with lib.maintainers; [
        luftmensch-luftmensch
        romildo
      ];

      platforms = lib.platforms.unix;
    };
  })
