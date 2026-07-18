{
  lib,
  stdenv,
  fetchurl,
  unzip,
  # To select only certain themes, pass `selected_themes` as a list of strings.
  # reference ./shas.nix for available themes
  selected_themes ? [ ],
}:
let
  version = "1.0";
  # this file is generated via ./update.sh
  # borrowed from pkgs/data/fonts/nerdfonts
  themeShas = import ./shas.nix;
  knownThemes = builtins.attrNames themeShas;
  selectedThemes =
    if (selected_themes == [ ]) then
      knownThemes
    else
      let
        unknown = lib.subtractLists knownThemes selected_themes;
      in
      if (unknown != [ ]) then
        throw "Unknown theme(s): ${lib.concatStringsSep " " unknown}"
      else
        selected_themes;
  srcs = lib.lists.forEach selectedThemes (
    name:
    (fetchurl {
      sha256 = themeShas.${name}.sha;
      url = themeShas.${name}.url;
    })
  );
in
stdenv.mkDerivation {
  inherit version srcs;
  pname = "adi1090x-plymouth-themes";

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    mkdir -p $out/share/plymouth/themes
    for theme in ${toString selectedThemes}; do
      mv $theme $out/share/plymouth/themes/$theme
    done
    find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;
  '';

  sourceRoot = ".";
  unpackCmd = "tar xzf $curSrc";

  meta = {
    description = "Plymouth boot themes from adi1090x";

    longDescription = ''
      A variety of plymouth boot screens by adi1090x.  Using the default value
      of `selected_themes` will install all themes (~524M).  Consider overriding
      this with a list of the string names of each theme to install.  Check
      ./shas.nix for available themes.
    '';

    homepage = "https://github.com/adi1090x/plymouth-themes";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ slwst ];
    platforms = lib.platforms.linux;
  };
}
