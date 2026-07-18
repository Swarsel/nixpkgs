{
  python3Packages,
  wox,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  inherit (wox)
    version
    src
    ;

  pname = "wox-plugin";

  build-system = with python3Packages; [
    hatchling
  ];

  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/wox.plugin.python";

  meta = {
    inherit (wox.meta)
      description
      homepage
      license
      maintainers
      ;
  };
})
