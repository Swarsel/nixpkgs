{
  lib,
  stdenv,
  nix,
  nixosTests,
  pkgs,
  pkgsStatic,
  pkgsi686Linux,
  runCommand,
  self_attribute_name,
  src,
  version,
}:
{
  /**
    Intended to test `lib`, but also a good smoke test for Nix
  */
  nixpkgs-lib = import ../../../../lib/tests/test-with-nix.nix {
    inherit lib pkgs;
    inherit nix;
  };

  srcVersion =
    runCommand "nix-src-version"
      {
        inherit version;
      }
      ''
        # This file is an implementation detail, but it's a good sanity check
        # If upstream changes that, we'll have to adapt.
        srcVersion=$(cat ${src}/.version)
        echo "Version in nix nix expression: $version"
        echo "Version in nix.src: $srcVersion"
        ${
          if self_attribute_name == "git" then
            # Major and minor must match, patch can be missing or have a suffix like a commit hash. That's all fine.
            ''
              majorMinor() {
                echo "$1" | sed -n -e 's/\([0-9]*\.[0-9]*\).*/\1/p'
              }
              if (set -x; [ "$(majorMinor "$version")" != "$(majorMinor "$srcVersion")" ]); then
                echo "Version mismatch!"
                exit 1
              fi
            ''
          else
            # Match base version, ignoring +suffix (which comes from patches)
            ''
              stripSuffix() {
                echo "$1" | sed 's/+.*//'
              }
              if [ "$(stripSuffix "$version")" != "$(stripSuffix "$srcVersion")" ]; then
                echo "Version mismatch!"
                exit 1
              fi
            ''
        }
        touch $out
      '';
}
// lib.optionalAttrs stdenv.hostPlatform.isLinux {
  # unfortunally nixpkgs pkgsStatic is too often broken including the dependency closure of nix
  # nixStatic = pkgsStatic.nixVersions.${self_attribute_name};
  # Basic smoke tests that needs to pass when upgrading nix.
  # Note that this test does only test the nixVersions.stable attribute.
  misc = nixosTests.nix-misc.default;
  simpleUefiSystemdBoot = nixosTests.installer.simpleUefiSystemdBoot;
  upgrade = nixosTests.nix-upgrade;
}
// lib.optionalAttrs (stdenv.hostPlatform.system == "x86_64-linux") {
  nixi686 = pkgsi686Linux.nixVersions.${self_attribute_name};
}
