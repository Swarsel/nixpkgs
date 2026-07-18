# Darwin-specific base builder.

{
  lib,
  excludeDrvArgNames,
  stdenvNoCC,
  undmg,
  ...
}:

lib.extendMkDerivation {
  inherit excludeDrvArgNames;
  constructDrv = stdenvNoCC.mkDerivation;

  extendDrvArgs =
    finalAttrs:
    {
      product,
      meta ? { },
      nativeBuildInputs ? [ ],
      productShort ? product,
      ...
    }:

    let
      loname = lib.toLower productShort;
    in
    {
      nativeBuildInputs = nativeBuildInputs ++ [ undmg ];

      installPhase = ''
        runHook preInstall
        APP_DIR="$out/Applications/${product}.app"
        mkdir -p "$APP_DIR"
        cp -Tr *.app "$APP_DIR"
        mkdir -p "$out/bin"
        cat << EOF > "$out/bin/${loname}"
        #!${stdenvNoCC.shell}
        open -na '$APP_DIR' --args "\$@"
        EOF
        chmod +x "$out/bin/${loname}"
        runHook postInstall
      '';

      desktopName = product;
      dontFixup = true;
      sourceRoot = ".";

      meta = meta // {
        mainProgram = loname;
      };
    };
}
