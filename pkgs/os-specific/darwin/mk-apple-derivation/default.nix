{
  lib,
  bootstrapStdenv,
  meson,
  ninja,
  runCommand,
  sourceRelease,
  xcodeProjectCheckHook,
}:

let
  prependShardPath =
    path:
    let
      shard = lib.toLower (lib.substring 0 2 path);
    in
    lib.foldl' lib.path.append ../by-name [
      shard
      path
    ];

  hasBasenamePrefix = prefix: file: lib.hasPrefix prefix (baseNameOf file);
in
lib.extendMkDerivation {
  constructDrv = bootstrapStdenv.mkDerivation;

  extendDrvArgs =
    finalAttrs: args:
    assert args ? releaseName;
    let
      inherit (args) releaseName;
      releaseSrc = sourceRelease releaseName;
      files = lib.filesystem.listFilesRecursive (prependShardPath releaseName);
      mesonFiles = lib.filter (hasBasenamePrefix "meson") files;
    in
    # You have to have at least `meson.build.in` when using xcodeHash to trigger the Meson
    # build support in `mkAppleDerivation`.
    assert args ? xcodeHash -> lib.length mesonFiles > 0;
    {
      inherit (releaseSrc) version;
      pname = args.pname or releaseName;
      src = args.src or releaseSrc;
      strictDeps = true;
      __structuredAttrs = true;

      meta = {
        homepage = "https://opensource.apple.com/releases/";
        license = lib.licenses.apple-psl20;
        platforms = lib.platforms.darwin;
        teams = [ lib.teams.darwin ];
      }
      // args.meta or { };
    }
    // lib.optionalAttrs (args ? xcodeHash) (
      let
        xcodeProject = args.xcodeProject or "${releaseName}.xcodeproj";
      in
      {
        inherit xcodeProject;

        nativeBuildInputs = args.nativeBuildInputs or [ ] ++ [
          meson
          ninja
          xcodeProjectCheckHook
        ];

        mesonBuildType = "release";

        postUnpack =
          args.postUnpack or ""
          + lib.concatMapStrings (
            file:
            if baseNameOf file == "meson.build.in" then
              "substitute ${lib.escapeShellArg "${file}"} \"$sourceRoot/meson.build\" --subst-var version\n"
            else
              "cp ${lib.escapeShellArg "${file}"} \"$sourceRoot/\"${lib.escapeShellArg (baseNameOf file)}\n"
          ) mesonFiles;

        # build-platform check so CI catches stale xcodeHashes the Darwin-only postUnpack hook misses
        passthru = lib.recursiveUpdate (args.passthru or { }) {
          tests.xcodeProjectHash =
            runCommand "${finalAttrs.pname}-xcodeproject-hash-check"
              {
                inherit xcodeProject;
                inherit (args) xcodeHash;
                nativeBuildInputs = [ xcodeProjectCheckHook ];
                sourceRoot = "${finalAttrs.src}";
              }
              ''
                verifyXcodeProjectHash
                touch "$out"
              '';
        };
      }
    );
}
