{
  lib,
  stdenv,
  wrapFish,
  writableTmpDirAsHomeHook,
  writeScript,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "checkPlugins"
    "checkFunctionDirs"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      buildPhase ? ":",
      # vendor directories to add to the function path of the test fish shell
      checkFunctionDirs ? [ ],
      # test script to be executed in a fish shell
      checkPhase ? "",
      # plugin packages to add to the vendor paths of the test fish shell
      checkPlugins ? [ ],
      configurePhase ? ":",
      doCheck ? checkPhase != "",
      name ? "fishplugin-${finalAttrs.pname}-${finalAttrs.version}",
      nativeCheckInputs ? [ ],
      unpackPhase ? "",
      ...
    }:
    {
      inherit name;
      inherit unpackPhase configurePhase buildPhase;
      inherit doCheck;

      nativeCheckInputs = [
        writableTmpDirAsHomeHook
        (wrapFish {
          functionDirs = checkFunctionDirs;
          pluginPkgs = checkPlugins;
        })
      ]
      ++ nativeCheckInputs;

      checkPhase = ''
        fish "${writeScript "${finalAttrs.name}-test" checkPhase}"
      '';

      installPhase = ''
        runHook preInstall

        (
          install_vendor_files() {
            source="$1"
            target="$out/share/fish/vendor_$2.d"

            # Check if any .fish file exists in $source
            [ -n "$(shopt -s nullglob; echo $source/*.fish)" ] || return 0

            mkdir -p $target
            cp $source/*.fish "$target/"
          }

          install_vendor_files completions completions
          install_vendor_files functions functions
          install_vendor_files conf conf
          install_vendor_files conf.d conf
        )

        runHook postInstall
      '';
    };
}
