/*
  How to combine packages for use in development:
  dotnetCombined = with dotnetCorePackages; combinePackages [ sdk_9_0 aspnetcore_8_0 ];

  Hashes and urls are retrieved from:
  https://dotnet.microsoft.com/download/dotnet
*/
{
  lib,
  buildPackages,
  config,
  generateSplicesForMkScope,
  makeScopeWithSplicing',
  newScope,
  writeScriptBin,
}:

makeScopeWithSplicing' {
  f = (
    self:
    let
      callPackage = self.callPackage;

      fetchNupkg = callPackage ../../../build-support/dotnet/fetch-nupkg { };

      buildDotnetSdk =
        let
          buildDotnet = attrs: callWithUtils (import ./binary/build-dotnet.nix attrs) { };
        in
        version:
        import version {
          inherit fetchNupkg;
          buildAspNetCore = attrs: buildDotnet (attrs // { type = "aspnetcore"; });
          buildNetRuntime = attrs: buildDotnet (attrs // { type = "runtime"; });
          buildNetSdk = attrs: buildDotnet (attrs // { type = "sdk"; });
        };

      runtimeIdentifierMap = {
        "aarch64-darwin" = "osx-arm64";
        "aarch64-linux" = "linux-arm64";
        "i686-windows" = "win-x86";
        "x86_64-linux" = "linux-x64";
        "x86_64-windows" = "win-x64";
      };

      # used to break cycle in attribute names
      callWithUtils = newScope (utils // { callPackage = callWithUtils; });

      utils = {
        inherit
          callPackage
          fetchNupkg
          buildDotnetSdk
          ;

        addNuGetDeps = callPackage ../../../build-support/dotnet/add-nuget-deps { };
        autoPatchcilHook = callPackage ../../../build-support/dotnet/auto-patchcil-hook { };
        buildDotnetGlobalTool = callPackage ../../../build-support/dotnet/build-dotnet-global-tool { };
        buildDotnetModule = callPackage ../../../build-support/dotnet/build-dotnet-module { };
        combinePackages = attrs: callPackage (import ./combine-packages.nix attrs) { };

        generate-dotnet-sdk = writeScriptBin "generate-dotnet-sdk" (
          # Don't include current nixpkgs in the exposed version. We want to make the script runnable without nixpkgs repo.
          builtins.replaceStrings [ " -I nixpkgs=./." ] [ "" ] (builtins.readFile ./binary/update.sh)
        );

        mkNugetDeps = callPackage ../../../build-support/dotnet/make-nuget-deps { };
        mkNugetSource = callPackage ../../../build-support/dotnet/make-nuget-source { };
        nugetPackageHook = callPackage ./nuget-package-hook.nix { };
        patchNupkgs = buildPackages.callPackage ./patch-nupkgs.nix { };

        # Convert a "stdenv.hostPlatform.system" to a dotnet RID
        systemToDotnetRid =
          system: runtimeIdentifierMap.${system} or (throw "unsupported platform ${system}");
      };

    in
    utils
    // (
      let
        dotnet_6 = callWithUtils ./dotnet.nix {
          channel = "6.0";
        };

        dotnet_7 = callWithUtils ./dotnet.nix {
          channel = "7.0";
        };

        dotnet_8 = callWithUtils ./dotnet.nix {
          channel = "8.0";
        };

        dotnet_9 = callWithUtils ./dotnet.nix {
          channel = "9.0";
        };

        dotnet_10 = callWithUtils ./dotnet.nix {
          channel = "10.0";
        };

        dotnet_11 = callWithUtils ./dotnet.nix {
          channel = "11.0";
        };
      in
      lib.optionalAttrs config.allowAliases {
        # EOL
        sdk_2_1 = throw "Dotnet SDK 2.1 is EOL, please use 8.0 (LTS) or 9.0 (Current)";
        sdk_2_2 = throw "Dotnet SDK 2.2 is EOL, please use 8.0 (LTS) or 9.0 (Current)";
        sdk_3_0 = throw "Dotnet SDK 3.0 is EOL, please use 8.0 (LTS) or 9.0 (Current)";
        sdk_3_1 = throw "Dotnet SDK 3.1 is EOL, please use 8.0 (LTS) or 9.0 (Current)";
        sdk_5_0 = throw "Dotnet SDK 5.0 is EOL, please use 8.0 (LTS) or 9.0 (Current)";
      }
      // lib.mergeAttrsList [
        dotnet_6
        dotnet_7
        dotnet_8
        dotnet_9
        dotnet_10
        dotnet_11
      ]
    )
  );

  otherSplices = generateSplicesForMkScope "dotnetCorePackages";
}
