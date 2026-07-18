{
  lib,
  callPackage,
  runCommand,
  sddm-unwrapped,
  wrapQtAppsHook,
  extraPackages ? [ ],
}:
runCommand "sddm-wrapped"
  {
    inherit (sddm-unwrapped) version outputs;
    pname = "sddm";
    strictDeps = true;
    nativeBuildInputs = [ wrapQtAppsHook ];
    buildInputs = sddm-unwrapped.buildInputs ++ extraPackages;

    passthru = {
      inherit (sddm-unwrapped.passthru) tests;
      unwrapped = sddm-unwrapped;
    };

    meta = sddm-unwrapped.meta;
  }
  ''
    mkdir -p $out/bin

    cd ${sddm-unwrapped}

    for i in *; do
      if [ "$i" == "bin" ]; then
        continue
      fi
      ln -s ${sddm-unwrapped}/$i $out/$i
    done

    for i in bin/*; do
      makeQtWrapper ${sddm-unwrapped}/$i $out/$i --set SDDM_GREETER_DIR $out/bin
    done

    mkdir -p $man
    ln -s ${lib.getMan sddm-unwrapped}/* $man/
  ''
