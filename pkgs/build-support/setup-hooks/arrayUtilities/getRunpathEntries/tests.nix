# NOTE: Tests related to getRunpathEntries go here.
{
  lib,
  stdenv,
  emptyFile,
  getRunpathEntries,
  hello,
  pkgsStatic,
  testers,
}:
let
  inherit (lib.attrsets) recurseIntoAttrs;
  inherit (testers)
    shellcheck
    shfmt
    testBuildFailure'
    testEqualArrayOrMap
    ;

  check =
    {
      elfFile,
      name,
      runpathEntries,
    }:
    (testEqualArrayOrMap {
      inherit name;
      expectedArray = runpathEntries;

      script = ''
        set -eu
        nixLog "running getRunpathEntries with ''${elfFile@Q} to populate actualArray"
        getRunpathEntries "$elfFile" actualArray || {
          nixErrorLog "getRunpathEntries failed"
          exit 1
        }
      '';
    }).overrideAttrs
      (prevAttrs: {
        inherit elfFile;
        nativeBuildInputs = prevAttrs.nativeBuildInputs or [ ] ++ [ getRunpathEntries ];

        meta = prevAttrs.meta or { } // {
          platforms = lib.platforms.linux;
        };
      });
in
recurseIntoAttrs {
  shellcheck = shellcheck {
    src = ./getRunpathEntries.bash;
    name = "getRunpathEntries";
  };

  shfmt = shfmt {
    src = ./getRunpathEntries.bash;
    name = "getRunpathEntries";
  };
}
# Only tested on Linux.
// lib.optionalAttrs stdenv.hostPlatform.isLinux {
  hello = check {
    elfFile = lib.getExe hello;
    name = "hello";

    runpathEntries = [
      "${lib.getLib stdenv.cc.libc}/lib"
    ];
  };

  libstdcplusplus = check {
    elfFile = "${lib.getLib stdenv.cc.cc}/lib/libstdc++.so";
    name = "libstdcplusplus";

    runpathEntries = [
      "${lib.getLib stdenv.cc.cc}/lib"
      "${lib.getLib stdenv.cc.libc}/lib"
    ];
  };

  # Not an ELF file
  notElfFileFails = testBuildFailure' {
    drv = check {
      elfFile = emptyFile;
      name = "notElfFile";
      runpathEntries = [ ];
    };

    expectedBuilderLogEntries = [
      "getRunpathEntries failed"
    ];

    name = "notElfFileFails";
  };

  # Not a dynamic ELF file
  staticElfFileFails = testBuildFailure' {
    drv = check {
      elfFile = lib.getExe pkgsStatic.hello;
      name = "staticElfFile";
      runpathEntries = [ ];
    };

    expectedBuilderLogEntries = [
      "getRunpathEntries failed"
    ];

    name = "staticElfFileFails";
  };
}
