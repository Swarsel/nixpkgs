{
  lib,
  erlang,
  pkgs,
}:

let
  inherit (lib) makeExtensible;

  # FIXME: add support for overrideScope
  callPackageWithScope =
    scope: drv: args:
    lib.callPackageWith scope drv args;
  callPackagesWithScope =
    scope: drv: args:
    lib.callPackagesWith scope drv args;
  mkScope = scope: pkgs // scope;

  packages =
    self:
    let
      defaultScope = mkScope self;
      callPackage = drv: args: callPackageWithScope defaultScope drv args;
      callPackages = drv: args: callPackagesWithScope defaultScope drv args;
    in
    rec {
      inherit callPackage erlang;
      inherit (callPackage ../tools/build-managers/rebar3 { }) rebar3 rebar3WithPlugins;

      inherit (callPackages ./hooks { })
        beamCopySourceHook
        beamModuleInstallHook
        mixBuildDirHook
        mixCompileHook
        mixAppConfigPatchHook
        rebar3CompileHook
        rebarDevendorPatchHook
        ;

      beamPackages = self;
      buildErlangMk = callPackage ./build-erlang-mk.nix { };
      buildMix = callPackage ./build-mix.nix { };
      buildRebar3 = callPackage ./build-rebar3.nix { };
      # BEAM-based languages.
      elixir = elixir_1_18;
      elixir-ls = callPackage ./elixir-ls { inherit elixir; };

      elixir_1_17 = callPackage ../interpreters/elixir/1.17.nix {
        inherit erlang;
        debugInfo = true;
      };

      elixir_1_18 = callPackage ../interpreters/elixir/1.18.nix {
        inherit erlang;
        debugInfo = true;
      };

      elixir_1_19 = callPackage ../interpreters/elixir/1.19.nix {
        inherit erlang;
        debugInfo = true;
      };

      elixir_1_20 = callPackage ../interpreters/elixir/1.20.nix {
        inherit erlang;
        debugInfo = true;
      };

      elvis-erlang = callPackage ./elvis-erlang { };
      erlfmt = callPackage ./erlfmt { };

      # Remove old versions of elixir, when the supports fades out:
      # https://hexdocs.pm/elixir/compatibility-and-deprecations.html
      ex_doc = callPackage ./ex_doc {
        inherit fetchMixDeps mixRelease;
      };

      expert = callPackage ./expert { };
      fetchHex = callPackage ./fetch-hex.nix { };
      fetchMixDeps = callPackage ./fetch-mix-deps.nix { };
      fetchRebar3Deps = callPackage ./fetch-rebar-deps.nix { };
      # Non hex packages. Examples how to build Rebar/Mix packages with and
      # without helper functions buildRebar3 and buildMix.
      hex = callPackage ./hex { };
      lfe = callPackage ../interpreters/lfe { inherit erlang buildRebar3 fetchHex; };
      livebook = callPackage ./livebook { inherit beamPackages; };
      mixRelease = callPackage ./mix-release.nix { };
      pc = callPackage ./pc { };
      rebar = callPackage ../tools/build-managers/rebar { };
      rebar3-nix = callPackage ./rebar3-nix { };
      rebar3-proper = callPackage ./rebar3-proper { };
      rebar3Relx = callPackage ./rebar3-release.nix { };
      webdriver = callPackage ./webdriver { };
    };
in
makeExtensible packages
