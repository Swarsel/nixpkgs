{
  lib,
  linkFarm,
  makeBinaryWrapper,
  packer,
  packerPlugins,
  stdenvNoCC,
}:
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [
    "derivationArgs"
    "selector"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      name ? "packer-with-plugins",
      nativeBuildInputs ? [ makeBinaryWrapper ],
      selector ? (_: [ ]),
      ...
    }:
    let
      plugins = selector packerPlugins;
      pluginFarm = linkFarm "packer-plugins" (
        builtins.concatMap (p: [
          {
            name = p.pluginPath;
            path = "${p}/bin/${p.meta.mainProgram}";
          }
          {
            name = "${p.pluginPath}_SHA256SUM";
            path = "${p}/bin/${p.meta.mainProgram}_SHA256SUM";
          }
        ]) plugins
      );
    in
    {
      inherit name nativeBuildInputs;
      strictDeps = true;
      __structuredAttrs = true;

      buildCommand = ''
        makeWrapper "${packer}/bin/packer" "$out/bin/packer" \
          --set PACKER_PLUGIN_PATH "${pluginFarm}"
      '';

      dontUnpack = true;
      meta.mainProgram = "packer";
    };
}
