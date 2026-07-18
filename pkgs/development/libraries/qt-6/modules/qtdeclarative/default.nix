{
  lib,
  stdenv,
  darwin,
  fetchpatch,
  # TODO: Clean up on `staging`.
  llvmPackages,
  openssl,
  pkgsBuildBuild,
  qtModule,
  qtbase,
  qtlanguageserver,
  qtshadertools,
  qtsvg,
  replaceVars,
}:

qtModule {
  pname = "qtdeclarative";

  patches = [
    # don't cache bytecode of bare qml files in the store, as that never gets cleaned up
    (replaceVars ./dont-cache-nix-store-paths.patch {
      nixStore = builtins.storeDir;
    })
    # add version specific QML import path
    ./use-versioned-import-path.patch

    # revert codesigning change on Darwin that doesn't work with our signing tools
    (fetchpatch {
      hash = "sha256-ESy35OlmsvI4yFQ/rFT8oelOUBCwCmlcbQJvwcTrCig=";
      revert = true;
      url = "https://github.com/qt/qtdeclarative/commit/a7084abd9778b955d80e7419e82f6f7b92f7978d.diff";
    })

    # backport fix recommended by KDE
    (fetchpatch {
      hash = "sha256-3KbyoQPAiRyCwGnwwYV3y0yz2i6UAJcX70EPsXV0ZZM=";
      url = "https://github.com/qt/qtdeclarative/commit/8a2c82be6ad90e3f2a0760d8bab1e3a8cdb2473a.diff";
    })

    # backport required at least for [musescore][1], and perhaps many other
    # applications.
    # [1]: https://github.com/musescore/MuseScore/issues/33015
    (fetchpatch {
      hash = "sha256-XhfliF5wZuN4/E55f8hfipIRjxBe9V7vL1cgn5p4xqA=";
      url = "https://github.com/qt/qtdeclarative/commit/9d4d376726a6ce15c429128dc65b927e411e40da.diff";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
    # TODO: Clean up on `staging`.
    llvmPackages.lld
  ];

  propagatedBuildInputs = [
    qtbase
    qtlanguageserver
    qtshadertools
    qtsvg
    openssl
  ];

  cmakeFlags = [
    "-DQt6ShaderToolsTools_DIR=${pkgsBuildBuild.qt6.qtshadertools}/lib/cmake/Qt6ShaderTools"
    # for some reason doesn't get found automatically on Darwin
    "-DPython_EXECUTABLE=${lib.getExe pkgsBuildBuild.python3}"
  ]
  # Conditional is required to prevent infinite recursion during a cross build
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DQt6QmlTools_DIR=${pkgsBuildBuild.qt6.qtdeclarative}/lib/cmake/Qt6QmlTools"
  ];

  env = lib.optionalAttrs (stdenv.hostPlatform.isDarwin) {
    # TODO: Clean up on `staging`.
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  meta.maintainers = with lib.maintainers; [
    nickcao
    outfoxxed
  ];
}
