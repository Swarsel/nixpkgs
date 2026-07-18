{
  lib,
  stdenv,
  pkgs,
}:

let
  inherit (lib.strings) concatStringsSep optionalString;
  inherit (pkgs) runCommand;
  inherit (pkgs.testers) testBuildFailure;

  mkDanglingSymlink = absolute: ''
    ln -s${optionalString (!absolute) "r"} "$out/dangling" "$out/dangling-symlink"
  '';

  mkReflexiveSymlink = absolute: ''
    ln -s${optionalString (!absolute) "r"} "$out/reflexive-symlink" "$out/reflexive-symlink"
  '';

  # Some platforms implement permissions for symlinks, while others - including Linux - ignore them.
  # As a result, testing this hook's handling of unreadable symlinks requires careful attention to
  # which kind of platform we're on. See the comments by `lib.optionalAttrs` below for details.
  hasSymlinkPermissions = with stdenv.hostPlatform; isDarwin || isBSD;
  mkUnreadableSymlink = absolute: ''
    touch "$out/unreadable-symlink-target"
    (
      umask 777
      ln -s${optionalString (!absolute) "r"} "$out/unreadable-symlink-target" "$out/unreadable-symlink"
    )
  '';

  mkValidSymlink = absolute: ''
    touch "$out/valid"
    ln -s${optionalString (!absolute) "r"} "$out/valid" "$out/valid-symlink"
  '';

  mkValidSymlinkOutsideNixStore = absolute: ''
    ln -s${optionalString (!absolute) "r"} "/etc/my_file" "$out/valid-symlink"
  '';

  testBuilder =
    {
      name,
      commands ? [ ],
      derivationArgs ? { },
    }:
    stdenv.mkDerivation (
      {
        inherit name;
        strictDeps = true;

        installPhase = ''
          mkdir -p "$out"

        ''
        + concatStringsSep "\n" commands;

        dontBuild = true;
        dontConfigure = true;
        dontPatch = true;
        dontUnpack = true;
      }
      // derivationArgs
    );
in
{
  fail-broken-symlinks-absolute =
    runCommand "fail-broken-symlinks-absolute"
      {
        failed = testBuildFailure (testBuilder {
          commands = [
            (mkDanglingSymlink true)
            (mkReflexiveSymlink true)
          ];

          name = "fail-broken-symlinks-absolute-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        grep -F 'found 1 dangling symlinks, 1 reflexive symlinks and 0 unreadable symlinks' "$failed/testBuildFailure.log"
        touch $out
      '';

  # Leave the unreadable symlink out of the combined 'broken' test since it doesn't work on all platforms.
  fail-broken-symlinks-relative =
    runCommand "fail-broken-symlinks-relative"
      {
        failed = testBuildFailure (testBuilder {
          commands = [
            (mkDanglingSymlink false)
            (mkReflexiveSymlink false)
          ];

          name = "fail-broken-symlinks-relative-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        grep -F 'found 1 dangling symlinks, 1 reflexive symlinks and 0 unreadable symlinks' "$failed/testBuildFailure.log"
        touch $out
      '';

  fail-dangling-symlink-absolute =
    runCommand "fail-dangling-symlink-absolute"
      {
        failed = testBuildFailure (testBuilder {
          commands = [ (mkDanglingSymlink true) ];
          name = "fail-dangling-symlink-absolute-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        grep -F 'found 1 dangling symlinks, 0 reflexive symlinks and 0 unreadable symlinks' "$failed/testBuildFailure.log"
        touch $out
      '';

  fail-dangling-symlink-relative =
    runCommand "fail-dangling-symlink-relative"
      {
        failed = testBuildFailure (testBuilder {
          commands = [ (mkDanglingSymlink false) ];
          name = "fail-dangling-symlink-relative-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        grep -F 'found 1 dangling symlinks, 0 reflexive symlinks and 0 unreadable symlinks' "$failed/testBuildFailure.log"
        touch $out
      '';

  fail-reflexive-symlink-absolute =
    runCommand "fail-reflexive-symlink-absolute"
      {
        failed = testBuildFailure (testBuilder {
          commands = [ (mkReflexiveSymlink true) ];
          name = "fail-reflexive-symlink-absolute-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        grep -F 'found 0 dangling symlinks, 1 reflexive symlinks and 0 unreadable symlinks' "$failed/testBuildFailure.log"
        touch $out
      '';

  fail-reflexive-symlink-relative =
    runCommand "fail-reflexive-symlink-relative"
      {
        failed = testBuildFailure (testBuilder {
          commands = [ (mkReflexiveSymlink false) ];
          name = "fail-reflexive-symlink-relative-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        grep -F 'found 0 dangling symlinks, 1 reflexive symlinks and 0 unreadable symlinks' "$failed/testBuildFailure.log"
        touch $out
      '';

  pass-broken-symlinks-absolute-allowed = testBuilder {
    commands = [
      (mkDanglingSymlink true)
      (mkReflexiveSymlink true)
    ];

    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-broken-symlinks-absolute-allowed";
  };

  pass-broken-symlinks-relative-allowed = testBuilder {
    commands = [
      (mkDanglingSymlink false)
      (mkReflexiveSymlink false)
    ];

    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-broken-symlinks-relative-allowed";
  };

  pass-dangling-symlink-absolute-allowed = testBuilder {
    commands = [ (mkDanglingSymlink true) ];
    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-dangling-symlink-absolute-allowed";
  };

  pass-dangling-symlink-relative-allowed = testBuilder {
    commands = [ (mkDanglingSymlink false) ];
    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-dangling-symlink-relative-allowed";
  };

  pass-reflexive-symlink-absolute-allowed = testBuilder {
    commands = [ (mkReflexiveSymlink true) ];
    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-reflexive-symlink-absolute-allowed";
  };

  pass-reflexive-symlink-relative-allowed = testBuilder {
    commands = [ (mkReflexiveSymlink false) ];
    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-reflexive-symlink-relative-allowed";
  };

  pass-valid-symlink-absolute = testBuilder {
    commands = [ (mkValidSymlink true) ];
    name = "pass-valid-symlink-absolute";
  };

  pass-valid-symlink-outside-nix-store-absolute = testBuilder {
    commands = [ (mkValidSymlinkOutsideNixStore true) ];
    name = "pass-valid-symlink-outside-nix-store-absolute";
  };

  pass-valid-symlink-outside-nix-store-relative = testBuilder {
    commands = [ (mkValidSymlinkOutsideNixStore false) ];
    name = "pass-valid-symlink-outside-nix-store-relative";
  };

  # The `all-broken` tests include unreadable symlinks along with the other kinds of broken links.
  # They should be run/skipped on the same sets platforms as the corresponding `unreadable` tests.
  # See below.
  pass-valid-symlink-relative = testBuilder {
    commands = [ (mkValidSymlink false) ];
    name = "pass-valid-symlink-relative";
  };
}
# Skip these tests if symlink permissions are not supported, since the hook won't have anything to report.
// lib.optionalAttrs hasSymlinkPermissions {
  fail-all-broken-symlinks-absolute =
    runCommand "fail-all-broken-symlinks-absolute"
      {
        failed = testBuildFailure (testBuilder {
          commands = [
            (mkDanglingSymlink true)
            (mkReflexiveSymlink true)
            (mkUnreadableSymlink true)
          ];

          name = "fail-all-broken-symlinks-absolute-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        if ! grep -F 'found 1 dangling symlinks, 1 reflexive symlinks and 1 unreadable symlinks' "$failed/testBuildFailure.log"; then
          grep -F 'symlink permissions not supported' "$failed/testBuildFailure.log"
          grep -F 'found 1 dangling symlinks, 1 reflexive symlinks and 0 unreadable symlinks' "$failed/testBuildFailure.log"
        fi
        touch $out
      '';

  fail-all-broken-symlinks-relative =
    runCommand "fail-all-broken-symlinks-relative"
      {
        failed = testBuildFailure (testBuilder {
          commands = [
            (mkDanglingSymlink false)
            (mkReflexiveSymlink false)
            (mkUnreadableSymlink false)
          ];

          name = "fail-all-broken-symlinks-relative-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        if ! grep -F 'found 1 dangling symlinks, 1 reflexive symlinks and 1 unreadable symlinks' "$failed/testBuildFailure.log"; then
          grep -F 'symlink permissions not supported' "$failed/testBuildFailure.log"
          grep -F 'found 1 dangling symlinks, 1 reflexive symlinks and 0 unreadable symlinks' "$failed/testBuildFailure.log"
        fi
        touch $out
      '';

  fail-unreadable-symlink-absolute =
    runCommand "fail-unreadable-symlink-absolute"
      {
        failed = testBuildFailure (testBuilder {
          commands = [ (mkUnreadableSymlink true) ];
          name = "fail-unreadable-symlink-absolute-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        grep -F 'found 0 dangling symlinks, 0 reflexive symlinks and 1 unreadable symlinks' "$failed/testBuildFailure.log"
        touch $out
      '';

  fail-unreadable-symlink-relative =
    runCommand "fail-unreadable-symlink-relative"
      {
        failed = testBuildFailure (testBuilder {
          commands = [ (mkUnreadableSymlink false) ];
          name = "fail-unreadable-symlink-relative-inner";
        });
      }
      ''
        (( 1 == "$(cat "$failed/testBuildFailure.exit")" ))
        grep -F 'found 0 dangling symlinks, 0 reflexive symlinks and 1 unreadable symlinks' "$failed/testBuildFailure.log"
        touch $out
      '';

}
# These tests will break on platforms that do use symlink permissions, because even though this hook will be okay, later ones will error out.
# They should be safe to run on other platforms, just to make sure the hook isn't completely broken. It won't have anything to report, though.
// lib.optionalAttrs (!hasSymlinkPermissions) {
  pass-all-broken-symlinks-absolute-allowed = testBuilder {
    commands = [
      (mkDanglingSymlink true)
      (mkReflexiveSymlink true)
      (mkUnreadableSymlink true)
    ];

    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-all-broken-symlinks-absolute-allowed";
  };

  pass-all-broken-symlinks-relative-allowed = testBuilder {
    commands = [
      (mkDanglingSymlink false)
      (mkReflexiveSymlink false)
      (mkUnreadableSymlink false)
    ];

    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-all-broken-symlinks-relative-allowed";
  };

  pass-unreadable-symlink-absolute-allowed = testBuilder {
    commands = [ (mkUnreadableSymlink true) ];
    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-unreadable-symlink-absolute-allowed";
  };

  pass-unreadable-symlink-relative-allowed = testBuilder {
    commands = [ (mkUnreadableSymlink false) ];
    derivationArgs.dontCheckForBrokenSymlinks = true;
    name = "pass-unreadable-symlink-relative-allowed";
  };
}
