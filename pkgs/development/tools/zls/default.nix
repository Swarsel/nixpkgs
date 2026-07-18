{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  zig_0_14,
  zig_0_15,
  zig_0_16,
}:

let
  common = finalAttrs: _: {
    pname = "zls";
    strictDeps = true;
    __structuredAttrs = true;

    zigBuildFlags = [
      "--system"
      "${finalAttrs.deps}"
    ];

    meta = {
      description = "Zig LSP implementation + Zig Language Server";
      homepage = "https://github.com/zigtools/zls";
      changelog = "https://github.com/zigtools/zls/releases/tag/${finalAttrs.version}";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        moni
        _0x5a4
        jmbaur
      ];

      platforms = lib.platforms.unix;
      mainProgram = "zls";
    };
  };
in
lib.mapAttrs (_: extension: stdenv.mkDerivation (lib.extends common extension)) {
  zls_0_14 = finalAttrs: {
    version = "0.14.0";

    src = fetchFromGitHub {
      owner = "zigtools";
      repo = "zls";
      tag = finalAttrs.version;
      hash = "sha256-A5Mn+mfIefOsX+eNBRHrDVkqFDVrD3iXDNsUL4TPhKo=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ zig_0_14 ];
    deps = callPackage ./deps_0_14.nix { };
  };

  zls_0_15 = finalAttrs: {
    version = "0.15.1";

    src = fetchFromGitHub {
      owner = "zigtools";
      repo = "zls";
      tag = finalAttrs.version;
      hash = "sha256-6IkRtQkn+qUHDz00QvCV/rb2yuF6xWEXug41CD8LLw8=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ zig_0_15 ];
    deps = callPackage ./deps_0_15.nix { };
  };

  zls_0_16 = finalAttrs: {
    version = "0.16.0";

    src = fetchFromGitHub {
      owner = "zigtools";
      repo = "zls";
      tag = finalAttrs.version;
      hash = "sha256-k0xWObsw9K12BKfK+UB5TieWDFEFfBQhN1X1NO35fWk=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ zig_0_16 ];
    deps = callPackage ./deps_0_16.nix { };
  };
}
