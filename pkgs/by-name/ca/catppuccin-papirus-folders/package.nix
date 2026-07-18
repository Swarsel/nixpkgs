{
  lib,
  fetchurl,
  fetchFromGitHub,
  getent,
  gtk3,
  papirus-icon-theme,
  stdenvNoCC,
  accent ? "blue",
  flavor ? "mocha",
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
  validFlavors = [
    "latte"
    "frappe"
    "macchiato"
    "mocha"
  ];
  pname = "catppuccin-papirus-folders";

  # Fetch the papirus-folders script from upstream
  # Per instructions in the papirus-folders project.
  papirus-folders-rev = "0f838ee5679229e3a3e97e3b333c222c9e9615b4";
  papirus-folders-script = fetchurl {
    executable = true;
    sha256 = "sha256-NJpXdf1ymnvQzRwUl3OalLzs3sXWVFTp5jN2B3vtUk0=";
    url = "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/${papirus-folders-rev}/papirus-folders";
  };
in
lib.checkListOfEnum "${pname}: accent colors" validAccents [ accent ] lib.checkListOfEnum
  "${pname}: flavors"
  validFlavors
  [ flavor ]
  stdenvNoCC.mkDerivation
  {
    inherit pname;
    version = "0-unstable-2024-08-06";

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "papirus-folders";
      rev = "f83671d17ea67e335b34f8028a7e6d78bca735d7";
      sha256 = "sha256-FiZdwzsaMhS+5EYTcVU1LVax2H1FidQw97xZklNH2R4=";
    };

    postPatch = ''
      cp ${papirus-folders-script} ./papirus-folders
      patchShebangs ./papirus-folders
    '';

    nativeBuildInputs = [
      gtk3
      getent
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/icons
      cp -r --no-preserve=mode ${papirus-icon-theme}/share/icons/Papirus* $out/share/icons
      cp -r src/* $out/share/icons/Papirus
      for theme in $out/share/icons/*; do
          USER_HOME=$HOME DISABLE_UPDATE_ICON_CACHE=1 \
            ./papirus-folders -t $theme -o -C cat-${flavor}-${accent}
          gtk-update-icon-cache --force $theme
      done
      runHook postInstall
    '';

    # This takes a horribly long time, and there's nothing to fixup in
    # this package.
    dontFixup = true;

    meta = {
      description = "Soothing pastel theme for Papirus Icon Theme folders";
      homepage = "https://github.com/catppuccin/papirus-folders";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ rubyowo ];
      platforms = lib.platforms.linux;
    };
  }
