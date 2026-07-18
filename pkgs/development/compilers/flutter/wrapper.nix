{
  lib,
  stdenv,
  atk,
  cairo,
  callPackage,
  clang,
  cmake,
  darwin,
  flutter,
  gdk-pixbuf,
  gitMinimal,
  glib,
  gtk3,
  harfbuzz,
  libdeflate,
  libepoxy,
  libx11,
  makeWrapper,
  ninja,
  pango,
  pkg-config,
  symlinkJoin,
  which,
  wrapGAppsHook3,
  writeShellScript,
  xorgproto,
  zlib,
  artifactHashes ? flutter.artifactHashes,
  extraCFlags ? [ ],
  extraCxxFlags ? [ ],
  extraIncludes ? [ ],
  extraLibraries ? [ ],
  extraLinkerFlags ? [ ],
  extraPkgConfigPackages ? [ ],
  supportedTargetFlutterPlatforms ? [
    "universal"
    "web"
  ]
  ++ lib.optional (stdenv.hostPlatform.isLinux && !(flutter ? engine)) "linux"
  ++ lib.optional (stdenv.hostPlatform.isx86_64 || stdenv.hostPlatform.isDarwin) "android"
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "macos"
    "ios"
  ],
}:

let
  supportsLinuxDesktopTarget = builtins.elem "linux" supportedTargetFlutterPlatforms;

  flutterPlatformArtifacts = lib.genAttrs supportedTargetFlutterPlatforms (
    flutterPlatform:
    (callPackage ./artifacts/prepare-artifacts.nix {
      src = callPackage ./artifacts/fetch-artifacts.nix {
        inherit flutterPlatform;
        hash = artifactHashes.${flutterPlatform}.${stdenv.hostPlatform.system} or "";
        flutter = callPackage ./wrapper.nix { inherit flutter; };
        systemPlatform = stdenv.hostPlatform.system;
      };
    })
  );

  cacheDir = symlinkJoin {
    postBuild = ''
      mkdir --parents "$out/bin/cache"
      ln --symbolic '${flutter}/bin/cache/dart-sdk' "$out/bin/cache"
    '';

    name = "flutter-cache-dir";
    paths = builtins.attrValues flutterPlatformArtifacts;
    passthru.flutterPlatform = flutterPlatformArtifacts;
  };

  # By default, Flutter stores downloaded files (such as the Pub cache) in the SDK directory.
  # Wrap it to ensure that it does not do that, preferring home directories instead.
  immutableFlutter = writeShellScript "flutter_immutable" ''
    export PUB_CACHE=''${PUB_CACHE:-"$HOME/.pub-cache"}
    ${flutter}/bin/flutter "$@"
  '';

  # Tools that the Flutter tool depends on.
  tools = [
    gitMinimal
    which
  ];

  # Libraries that Flutter apps depend on at runtime.
  appRuntimeDeps = lib.optionals supportsLinuxDesktopTarget [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    libepoxy
    pango
    libx11
    libdeflate
  ];

  # Development packages required for compilation.
  appBuildDeps =
    let
      # https://discourse.nixos.org/t/handling-transitive-c-dependencies/5942/3
      deps =
        pkg: lib.filter lib.isDerivation ((pkg.buildInputs or [ ]) ++ (pkg.propagatedBuildInputs or [ ]));
      withKey = pkg: {
        key = pkg.outPath;
        val = pkg;
      };
      collect = pkg: lib.map withKey ([ pkg ] ++ deps pkg);
    in
    lib.map (e: e.val) (
      lib.genericClosure {
        operator = item: collect item.val;
        startSet = lib.map withKey appRuntimeDeps;
      }
    );

  # Some header files and libraries are not properly located by the Flutter SDK.
  # They must be manually included.
  appStaticBuildDeps =
    (lib.optionals supportsLinuxDesktopTarget [
      libx11
      xorgproto
      zlib
    ])
    ++ extraLibraries;

  # Tools used by the Flutter SDK to compile applications.
  buildTools = lib.optionals supportsLinuxDesktopTarget [
    pkg-config
    cmake
    ninja
    clang
  ];

  # Nix-specific compiler configuration.
  pkgConfigPackages = map (lib.getOutput "dev") (appBuildDeps ++ extraPkgConfigPackages);
  includeFlags = map (pkg: "-isystem ${lib.getOutput "dev" pkg}/include") (
    appStaticBuildDeps ++ extraIncludes
  );
  linkerFlags =
    (map (pkg: "-rpath,${lib.getOutput "lib" pkg}/lib") appRuntimeDeps) ++ extraLinkerFlags;
in
(callPackage ./sdk-symlink.nix { }) (
  stdenv.mkDerivation {
    inherit (flutter) version;
    inherit (flutter) meta;
    pname = "flutter-wrapped";
    strictDeps = true;

    nativeBuildInputs = [
      makeWrapper
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.DarwinTools ]
    ++ lib.optionals supportsLinuxDesktopTarget [
      glib
      wrapGAppsHook3
    ];

    installPhase = ''
      runHook preInstall

      for path in ${
        builtins.concatStringsSep " " (
          builtins.foldl' (
            paths: pkg:
            paths
            ++ (map (directory: "'${pkg}/${directory}/pkgconfig'") [
              "lib"
              "share"
            ])
          ) [ ] pkgConfigPackages
        )
      }; do
        addToSearchPath FLUTTER_PKG_CONFIG_PATH "$path"
      done

      mkdir --parents $out/bin
      makeWrapper '${immutableFlutter}' $out/bin/flutter \
        --set-default ANDROID_EMULATOR_USE_SYSTEM_LIBS 1 \
    ''
    + lib.optionalString (flutter ? engine && flutter.engine.meta.available) ''
      --set-default FLUTTER_ENGINE "${flutter.engine}" \
      --add-flags "--local-engine-host ${flutter.engine.outName}" \
    ''
    + ''
        --suffix PATH : '${lib.makeBinPath (tools ++ buildTools)}' \
        --suffix PKG_CONFIG_PATH : "$FLUTTER_PKG_CONFIG_PATH" \
        --suffix LIBRARY_PATH : '${lib.makeLibraryPath appStaticBuildDeps}' \
        --prefix CXXFLAGS "''\t" '${builtins.concatStringsSep " " (includeFlags ++ extraCxxFlags)}' \
        --prefix CFLAGS "''\t" '${builtins.concatStringsSep " " (includeFlags ++ extraCFlags)}' \
        --prefix LDFLAGS "''\t" '${
          builtins.concatStringsSep " " (map (flag: "-Wl,${flag}") linkerFlags)
        }' \
        ''${gappsWrapperArgs[@]}

      runHook postInstall
    '';

    __structuredAttrs = true;
    dontUnpack = true;
    dontWrapGApps = true;

    passthru = flutter.passthru // {
      inherit (flutter) version;
      inherit cacheDir;
      unwrapped = flutter;
      updateScript = ./update/update.py;
    };
  }
)
