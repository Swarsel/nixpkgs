# similar to interpreters/python/default.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  makeBinaryWrapper,
}:

let

  # Common passthru for all lua interpreters.
  # copied from python
  passthruFun =
    {
      executable,
      luaOnBuildForBuild,
      luaOnBuildForHost,
      luaOnBuildForTarget,
      luaOnHostForHost,
      luaOnTargetForTarget,
      luaversion,
      packageOverrides,
      self, # is luaOnHostForTarget
      luaAttr ? null,
    }:
    let
      luaPackages =
        callPackage
          # Function that when called
          # - imports lua-packages.nix
          # - adds spliced package sets to the package set
          # - applies overrides from `packageOverrides`
          (
            {
              callPackage,
              lua,
              makeScopeWithSplicing',
              overrides,
            }:
            let
              luaPackagesFun = callPackage ../../../top-level/lua-packages.nix {
                lua = self;
              };
              generatedPackages =
                if (builtins.pathExists ../../lua-modules/generated-packages.nix) then
                  (
                    final: prev:
                    callPackage ../../lua-modules/generated-packages.nix { inherit (final) callPackage; } final prev
                  )
                else
                  (final: prev: { });
              overriddenPackages = callPackage ../../lua-modules/overrides.nix { };

              otherSplices = {
                selfBuildBuild = luaOnBuildForBuild.pkgs;
                selfBuildHost = luaOnBuildForHost.pkgs;
                selfBuildTarget = luaOnBuildForTarget.pkgs;
                selfHostHost = luaOnHostForHost.pkgs;
                selfTargetTarget = luaOnTargetForTarget.pkgs or { };
              };

              extensions = lib.composeManyExtensions [
                generatedPackages
                overriddenPackages
                overrides
              ];
            in
            makeScopeWithSplicing' {
              inherit otherSplices;
              f = lib.extends extensions luaPackagesFun;
            }
          )
          {
            lua = self;
            overrides = packageOverrides;
          };
    in
    rec {
      inherit executable luaversion;

      inherit
        luaOnBuildForBuild
        luaOnBuildForHost
        luaOnBuildForTarget
        luaOnHostForHost
        luaOnTargetForTarget
        ;

      inherit luaAttr;

      buildEnv = callPackage ./wrapper.nix {
        inherit (luaPackages) requiredLuaModules;
        lua = self;
        makeWrapper = makeBinaryWrapper;
      };

      interpreter = "${self}/bin/${executable}";

      luaOnBuild = luaOnBuildForHost.override {
        inherit packageOverrides;
        self = luaOnBuild;
      };

      pkgs = luaPackages;

      tests = callPackage ./tests {
        inherit (luaPackages) wrapLua;
        lua = self;
      };

      withPackages = import ./with-packages.nix { inherit buildEnv luaPackages; };
    };

in

rec {
  lua5_1 = callPackage ./interpreter.nix {
    inherit passthruFun;
    version = "5.1.5";

    patches = (lib.optional stdenv.hostPlatform.isDarwin ./5.1.darwin.patch) ++ [
      ./CVE-2014-5461.patch
    ];

    hash = "2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333";
    makeWrapper = makeBinaryWrapper;
    self = lua5_1;
  };

  lua5_2 = callPackage ./interpreter.nix {
    inherit passthruFun;
    version = "5.2.4";

    patches = [
      ./CVE-2022-28805.patch
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin ./5.2.darwin.patch;

    hash = "0jwznq0l8qg9wh5grwg07b5cy3lzngvl5m2nl1ikp6vqssmf9qmr";
    makeWrapper = makeBinaryWrapper;
    self = lua5_2;
  };

  lua5_2_compat = lua5_2.override {
    compat = true;
    self = lua5_2_compat;
  };

  lua5_3 = callPackage ./interpreter.nix {
    inherit passthruFun;
    version = "5.3.6";
    patches = lib.optionals stdenv.hostPlatform.isDarwin [ ./5.2.darwin.patch ];
    hash = "0q3d8qhd7p0b7a4mh9g7fxqksqfs6mr1nav74vq26qvkp2dxcpzw";
    makeWrapper = makeBinaryWrapper;
    self = lua5_3;
  };

  lua5_3_compat = lua5_3.override {
    compat = true;
    self = lua5_3_compat;
  };

  lua5_4 = callPackage ./interpreter.nix {
    inherit passthruFun;
    version = "5.4.7";
    patches = lib.optional stdenv.hostPlatform.isDarwin ./5.4.darwin.patch;
    hash = "sha256-n79eKO+GxphY9tPTTszDLpEcGii0Eg/z6EqqcM+/HjA=";
    makeWrapper = makeBinaryWrapper;
    self = lua5_4;
  };

  lua5_4_compat = lua5_4.override {
    compat = true;
    self = lua5_4_compat;
  };

  lua5_5 = callPackage ./interpreter.nix {
    inherit passthruFun;
    version = "5.5.0";
    patches = lib.optional stdenv.hostPlatform.isDarwin ./5.5.darwin.patch;
    hash = "sha256-V8zDK7vQBcq3W8xSREBSU1r2kXiduiuQFtXFBkDWiz0=";
    makeWrapper = makeBinaryWrapper;
    self = lua5_5;
  };

  lua5_5_compat = lua5_5.override {
    compat = true;
    self = lua5_5_compat;
  };

  luajit_2_0 = import ../luajit/2.0.nix {
    inherit
      callPackage
      fetchFromGitHub
      lib
      passthruFun
      ;

    self = luajit_2_0;
  };

  luajit_2_1 = import ../luajit/2.1.nix {
    inherit callPackage fetchFromGitHub passthruFun;
    self = luajit_2_1;
  };

  luajit_openresty = import ../luajit/openresty.nix {
    inherit callPackage fetchFromGitHub passthruFun;
    self = luajit_openresty;
  };
}
