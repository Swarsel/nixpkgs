{
  lib,
  python3Packages,
  qt6,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  # Inheriting src too, to hint nix-update
  inherit (python3Packages.optiland) version src;
  pname = "optiland-python-env";
  strictDeps = true;

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  # Modelded after `python.buildEnv`'s postBuild, but we don't link paths at
  # all, only create $out/bin/optiland (and potentially more) executable(s).
  buildPhase = ''
    mkdir -p $out/bin
    cd ${python3Packages.optiland}/bin
    for prg in *; do
      if [ -f "$prg" ] && [ -x "$prg" ]; then
        makeWrapper "${python3Packages.optiland}/bin/$prg" "$out/bin/$prg" \
          --set NIX_PYTHONPREFIX "$out" \
          --set NIX_PYTHONEXECUTABLE "${placeholder "out"}/bin/${python3Packages.python.executable}" \
          --set NIX_PYTHONPATH ${finalAttrs.finalPackage.passthru.pythonPath} \
          --set PYTHONNOUSERSITE "true" \
          ${lib.concatStringsSep " " finalAttrs.finalPackage.passthru.makeWrapperArgs}
      fi
    done
  '';

  __structuredAttrs = true;
  dontConfigure = true;
  dontInstall = true;
  dontUnpack = true;

  passthru = {
    makeWrapperArgs = [
      # leaving here room for potential additional arguments
    ];

    pythonPath =
      lib.makeSearchPathOutput "out" python3Packages.python.sitePackages
        finalAttrs.finalPackage.passthru.pythonPaths;

    pythonPaths = python3Packages.requiredPythonModules (
      [
        python3Packages.optiland
        python3Packages.python
      ]
      ++ python3Packages.optiland.passthru.optional-dependencies.gui
      ++ python3Packages.optiland.passthru.optional-dependencies.torch
    );
  };

  meta = python3Packages.optiland.meta // {
    description = python3Packages.optiland.meta.description + "; The GUI";
    mainProgram = "optiland";
  };
})
