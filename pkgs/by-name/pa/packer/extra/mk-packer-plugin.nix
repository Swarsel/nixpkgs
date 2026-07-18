let
  platformSuffix = {
    aarch64-darwin = "darwin_arm64";
    aarch64-linux = "linux_arm64";
    x86_64-linux = "linux_amd64";
  };
in

{
  lib,
  stdenv,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

lib.extendMkDerivation {
  constructDrv = buildGoModule;

  excludeDrvArgNames = [
    "apiVersion"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      pname,
      src,
      version,
      apiVersion ? "x5.0",
      doInstallCheck ? true,
      ldflags ? [ ],
      nativeInstallCheckInputs ? [ ],
      postFixup ? "",
      subPackages ? [ "." ],
      versionCheckProgramArg ? "describe",
      ...
    }@prevAttrs:
    # Packer expects plugins to be hosted on GitHub and follow a specific release structure
    # (see: https://developer.hashicorp.com/packer/docs/plugins/creation#creating-a-github-release).
    # This introduces two requirements:
    #
    # 1. Directory Structure: Packer expects the plugin binary to reside in:
    #    $PACKER_PLUGIN_PATH/github.com/$OWNER/$TYPE/
    #    where $TYPE is the repo name without the "packer-plugin-" prefix.
    #
    # 2. Configuration Source: When declaring the plugin in a Packer template, the `source`
    #    attribute must match this GitHub address format (e.g.: "github.com/$OWNER/$TYPE")
    let
      _ = lib.assertMsg (
        src ? repo && src ? owner && src ? githubBase
      ) "mk-packer-plugin: fetchFromGitHub is currently the only supported fetcher";
      suffix =
        platformSuffix."${stdenv.hostPlatform.system}"
          or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
      binName = "${finalAttrs.src.repo}_v${finalAttrs.version}_${apiVersion}_${suffix}";
    in
    {
      inherit
        subPackages
        doInstallCheck
        versionCheckProgramArg
        ;

      strictDeps = true;
      nativeInstallCheckInputs = nativeInstallCheckInputs ++ [ versionCheckHook ];

      # Generate checksums AFTER fixup phase when binary is finalized
      postFixup = postFixup + ''
        mv "$out/bin/${finalAttrs.src.repo}" "$out/bin/${binName}"
        sha256sum "$out/bin/${binName}" | cut -d' ' -f1 > "$out/bin/${binName}_SHA256SUM"
      '';

      __structuredAttrs = true;

      ldflags =
        ldflags
        ++ (
          let
            versionFlag = "${finalAttrs.src.githubBase}/${finalAttrs.src.owner}/${finalAttrs.src.repo}/version";
          in
          [
            "-s"
            "-w"
            "-X ${versionFlag}.Version=${finalAttrs.version}"
            "-X ${versionFlag}.VersionPrerelease="
          ]
        );

      versionCheckProgram = prevAttrs.versionCheckProgram or "${placeholder "out"}/bin/${binName}";

      passthru = {
        pluginPath = "${finalAttrs.src.githubBase}/${finalAttrs.src.owner}/${lib.removePrefix "packer-plugin-" finalAttrs.src.repo}/${binName}";
        updateScript = prevAttrs.passthru.updateScript or (nix-update-script { });
      };

      meta.mainProgram = binName;
    };
}
