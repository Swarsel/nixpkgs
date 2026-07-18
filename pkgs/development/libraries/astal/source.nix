{
  lib,
  fetchFromGitHub,
  nix-update-script,
}:
let
  originalDrv = fetchFromGitHub {
    hash = "sha256-bXd034/ARs18ZQ7hWUAw9NwyfBmcKQws8DQHzwYp6jM=";
    owner = "Aylur";
    repo = "astal";
    rev = "04454c22094401cc8e682cfe1f8ecc3194cac5f9";
  };
in
originalDrv.overrideAttrs (
  final: prev: {
    pname = "astal-source";
    version = "0-unstable-2026-07-03";
    name = "${final.pname}-${final.version}"; # fetchFromGitHub already defines name

    passthru = prev.passthru // {
      src = originalDrv;
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
    };

    meta = prev.meta // {
      description = "Building blocks for creating custom desktop shells (source)";

      longDescription = ''
        Please don't use this package directly, use one of subpackages in
        `astal` namespace. This package is just a `fetchFromGitHub`, which is
        reused between all subpackages.
      '';

      maintainers = with lib.maintainers; [ PerchunPak ];
      platforms = lib.platforms.linux;
    };
  }
)
