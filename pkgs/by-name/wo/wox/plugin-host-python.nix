{
  callPackage,
  python3Packages,
  wox,
  writableTmpDirAsHomeHook,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  inherit (wox) version src;
  pname = "wox-plugin-host-python";

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  buildInputs = with python3Packages; [
    loguru
    websockets
    finalAttrs.passthru.plugin-python
  ];

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    loguru
    websockets
    finalAttrs.passthru.plugin-python
  ];

  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/wox.plugin.host.python";

  passthru = {
    plugin-python = callPackage ./plugin-python.nix { };
  };

  meta = {
    inherit (wox.meta)
      description
      homepage
      license
      maintainers
      ;
  };
})
