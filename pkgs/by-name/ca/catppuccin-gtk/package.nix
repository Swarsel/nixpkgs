{
  lib,
  fetchFromGitHub,
  git,
  gtk3,
  nix-update-script,
  python3,
  sassc,
  stdenvNoCC,
  accents ? [ "blue" ],
  size ? "standard",
  tweaks ? [ ],
  variant ? "frappe",
}:
let
  validAccents = [
    "blue"
    "flamingo"
    "green"
    "lavender"
    "maroon"
    "mauve"
    "peach"
    "pink"
    "red"
    "rosewater"
    "sapphire"
    "sky"
    "teal"
    "yellow"
  ];
  validSizes = [
    "standard"
    "compact"
  ];
  validTweaks = [
    "black"
    "rimless"
    "normal"
    "float"
  ];
  validVariants = [
    "latte"
    "frappe"
    "macchiato"
    "mocha"
  ];

  pname = "catppuccin-gtk";
  version = "1.0.3";
in

lib.checkListOfEnum "${pname}: theme accent" validAccents accents lib.checkListOfEnum
  "${pname}: color variant"
  validVariants
  [ variant ]
  lib.checkListOfEnum
  "${pname}: size variant"
  validSizes
  [ size ]
  lib.checkListOfEnum
  "${pname}: tweaks"
  validTweaks
  tweaks

  stdenvNoCC.mkDerivation
  {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "gtk";
      tag = "v${version}";
      hash = "sha256-q5/VcFsm3vNEw55zq/vcM11eo456SYE5TQA3g2VQjGc=";
      fetchSubmodules = true;
    };

    patches = [
      ./fix-inconsistent-theme-name.patch
      ./python-3.14.patch # Fix build with python 3.14+
    ];

    nativeBuildInputs = [
      gtk3
      sassc
      # git is needed here since "git apply" is being used for patches
      # see <https://github.com/catppuccin/gtk/blob/4173b70b910bbb3a42ef0e329b3e98d53cef3350/build.py#L465>
      git
      (python3.withPackages (ps: [ ps.catppuccin ]))
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes

      python3 build.py ${variant} \
        --accent ${toString accents} \
        ${lib.optionalString (size != [ ]) "--size " + size} \
        ${lib.optionalString (tweaks != [ ]) "--tweaks " + toString tweaks} \
        --dest $out/share/themes

      runHook postInstall
    '';

    dontBuild = true;
    dontConfigure = true;
    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Soothing pastel theme for GTK";
      homepage = "https://github.com/catppuccin/gtk";
      license = lib.licenses.gpl3Plus;

      maintainers = with lib.maintainers; [
        fufexan
        dixslyf
        isabelroses
      ];

      platforms = lib.platforms.all;
    };
  }
