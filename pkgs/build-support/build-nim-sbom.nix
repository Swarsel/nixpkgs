{
  lib,
  stdenv,
  fetchgit,
  fetchzip,
  lndir,
  nim,
  nimOverrides,
  runCommand,
}:

let
  fetchers = {
    fetchgit =
      {
        rev,
        sha256,
        url,
        fetchSubmodules ? false,
        leaveDotGit ? false,
        ...
      }:
      fetchgit {
        inherit
          fetchSubmodules
          leaveDotGit
          rev
          sha256
          url
          ;
      };

    fetchzip =
      { sha256, url, ... }:
      fetchzip {
        inherit url sha256;
        name = "source";
      };
  };

  filterPropertiesToAttrs =
    prefix: properties:
    lib.pipe properties [
      (builtins.filter ({ name, ... }: (lib.strings.hasPrefix prefix name)))
      (map (
        { name, value }:
        {
          inherit value;
          name = lib.strings.removePrefix prefix name;
        }
      ))
      builtins.listToAttrs
    ];

  buildNimCfg =
    { backend, components, ... }:
    let
      componentSrcDirs = map (
        { properties, ... }:
        let
          fodProps = filterPropertiesToAttrs "nix:fod:" properties;
          fod = fetchers.${fodProps.method} fodProps;
          srcDir = fodProps.srcDir or "";
        in
        if srcDir == "" then fod else "${fod}/${srcDir}"
      ) components;
    in
    runCommand "nim.cfg"
      {
        outputs = [
          "out"
          "src"
        ];

        nativeBuildInputs = [ lndir ];
      }
      ''
        cat << EOF >> $out
        backend:${backend}
        path:"$src"
        EOF
        mkdir -p "$src"
        ${lib.strings.concatMapStrings (d: ''
          lndir "${d}" "$src"
        '') componentSrcDirs}
      '';

  buildCommands = lib.attrsets.mapAttrsToList (
    output: input: ''
      nim compile $nimFlags --out:${output} ${input}
    ''
  );

  installCommands = lib.attrsets.mapAttrsToList (
    output: input: ''
      install -Dt $out/bin ${output}
    ''
  );

  applySbom =
    sbom:
    {
      nimFlags ? [ ],
      nimRelease ? true,
      passthru ? { },
      ...
    }@prevAttrs:
    let
      properties = # SBOM metadata.component.properties as an attrset.
        lib.attrsets.recursiveUpdate (builtins.listToAttrs sbom.metadata.component.properties)
          passthru.properties or { };

      nimBin = # A mapping of Nim module file paths to names of programs.
        lib.attrsets.recursiveUpdate (lib.pipe properties [
          (lib.attrsets.filterAttrs (name: value: lib.strings.hasPrefix "nim:bin:" name))
          (lib.attrsets.mapAttrs' (
            name: value: {
              name = lib.strings.removePrefix "nim:bin:" name;
              value = "${properties."nim:binDir" or (properties."nim:srcDir" or ".")}/${value}";
            }
          ))
        ]) passthru.nimBin or { };
    in
    {
      pname = prevAttrs.pname or sbom.metadata.component.name;
      version = prevAttrs.version or sbom.metadata.component.version or null;
      strictDeps = true;
      nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [ nim ];

      buildPhase =
        prevAttrs.buildPhase or ''
          runHook preBuild
          ${lib.strings.concatLines (buildCommands nimBin)}
          runHook postBuild
        '';

      installPhase =
        prevAttrs.installPhase or ''
          runHook preInstall
          ${lib.strings.concatLines (installCommands nimBin)}
          runHook postInstall
        '';

      configurePhase =
        prevAttrs.configurePhase or ''
          runHook preConfigure
          echo "nim.cfg << $nimCfg"
          cat $nimCfg >> nim.cfg
          cat << EOF >> nim.cfg
          nimcache:"$NIX_BUILD_TOP/nimcache"
          parallelBuild:$NIX_BUILD_CORES
          EOF
          runHook postConfigure
        '';

      nimCfg =
        prevAttrs.nimCfg or (buildNimCfg {
          inherit (sbom) components;
          backend = prevAttrs.nimBackend or properties."nim:backend" or "c";
        });

      nimFlags =
        nimFlags
        ++ (lib.optional nimRelease "-d:release")
        ++ (
          let
            srcDir = properties."nim:srcDir" or "";
          in
          lib.optional (srcDir != "") "--path:${srcDir}"
        );

      passthru = passthru // {
        inherit sbom properties nimBin;
      };
    };

  applyOverrides =
    prevAttrs:
    builtins.foldl' (
      prevAttrs:
      { name, ... }@component:
      if (builtins.hasAttr name nimOverrides) then
        let
          result = nimOverrides.${name} component prevAttrs;
        in
        prevAttrs // (if builtins.isAttrs result then result else result { })
      else
        prevAttrs
    ) prevAttrs prevAttrs.passthru.sbom.components;

  compose =
    callerArg: sbom: finalAttrs:
    let
      callerAttrs = if builtins.isAttrs callerArg then callerArg else callerArg finalAttrs;
      sbomAttrs = callerAttrs // (applySbom sbom callerAttrs);
      overrideAttrs = sbomAttrs // (applyOverrides sbomAttrs);
    in
    overrideAttrs;
in
callerArg: sbomArg:
let
  sbom = if builtins.isAttrs sbomArg then sbomArg else builtins.fromJSON (builtins.readFile sbomArg);
  overrideSbom = f: stdenv.mkDerivation (compose callerArg (sbom // (f sbom)));
in
(stdenv.mkDerivation (compose callerArg sbom)) // { inherit overrideSbom; }
