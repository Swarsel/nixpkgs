{
  lib,
  fetchFromGitHub,
  catppuccin-whiskers,
  inkscape,
  just,
  python3,
  python3Packages,
  stdenvNoCC,
  xcursorgen,
  zip,
}:
let
  dimensions = {
    color = [
      "Blue"
      "Dark"
      "Flamingo"
      "Green"
      "Lavender"
      "Light"
      "Maroon"
      "Mauve"
      "Peach"
      "Pink"
      "Red"
      "Rosewater"
      "Sapphire"
      "Sky"
      "Teal"
      "Yellow"
    ];

    palette = [
      "frappe"
      "latte"
      "macchiato"
      "mocha"
    ];
  };
  variantName = { color, palette }: palette + color;
  variants = lib.mapCartesianProduct variantName dimensions;
  version = "2.0.0";
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "catppuccin-cursors";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "cursors";
    rev = "v${version}";
    hash = "sha256-qis6p+/m7+DdRDYzLq9yB2eZGpfZe5z5xRsa/1HoIG4=";
  };

  outputs = variants ++ [ "out" ]; # dummy "out" output to prevent breakage

  nativeBuildInputs = [
    just
    inkscape
    xcursorgen
    catppuccin-whiskers
    python3
    python3Packages.pyside6
    zip
  ];

  buildPhase = ''
    runHook preBuild

    patchShebangs .

    just all

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    for output in $(getAllOutputNames); do
      if [ "$output" != "out" ]; then
        local outputDir="''${!output}"
        local iconsDir="$outputDir"/share/icons

        mkdir -p "$iconsDir"

        # Convert to kebab case with the first letter of each word capitalized
        local variant=$(sed 's/\([A-Z]\)/-\1/g' <<< "$output")
        local variant=''${variant,,}

        mv "dist/catppuccin-$variant-cursors" "$iconsDir"
      fi
    done

    # Needed to prevent breakage
    mkdir -p "$out"

    runHook postInstall
  '';

  outputsToInstall = [ ];

  meta = {
    description = "Catppuccin cursor theme based on Volantes";
    homepage = "https://github.com/catppuccin/cursors";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ dixslyf ];
    platforms = lib.platforms.linux;
  };
}
