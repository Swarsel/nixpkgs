{
  lib,
  stdenv,
  buildPackages,
  cctools,
  fetchNpmDeps,
  nodejs,
}@topLevelArgs:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  extendDrvArgs =
    finalAttrs:
    {
      buildInputs ? [ ],
      # Whether to force allow an empty dependency cache.
      # This can be enabled if there are truly no remote dependencies, but generally an empty cache indicates something is wrong.
      forceEmptyCache ? false,
      # Whether to force the usage of Git dependencies that have install scripts, but not a lockfile.
      # Use with care.
      forceGitDeps ? false,
      # Whether to make the cache writable prior to installing dependencies.
      # Don't set this unless npm tries to write to the cache directory, as it can slow down the build.
      makeCacheWritable ? false,
      name ? "${args.pname}-${args.version}",
      nativeBuildInputs ? [ ],
      nodejs ? topLevelArgs.nodejs,
      # Flags to pass to `npm run ${npmBuildScript}`.
      npmBuildFlags ? [ ],
      # Custom npmBuildHook
      npmBuildHook ? null,
      # The script to run to build the project.
      npmBuildScript ? "build",
      # Custom npmConfigHook
      npmConfigHook ? null,
      npmDeps ? fetchNpmDeps {
        inherit
          forceGitDeps
          forceEmptyCache
          src
          srcs
          sourceRoot
          prePatch
          patches
          postPatch
          patchFlags
          ;

        fetcherVersion = npmDepsFetcherVersion;
        hash = npmDepsHash;
        name = "${name}-npm-deps";
      },
      # Fetcher format version for npmDeps. Set to 2 to enable packument caching
      # for workspace support. Changing this will invalidate npmDepsHash.
      npmDepsFetcherVersion ? 1,
      # The output hash of the dependencies for this project.
      # Can be calculated in advance with prefetch-npm-deps.
      npmDepsHash ? "",
      # Flags to pass to all npm commands.
      npmFlags ? [ ],
      # Flags to pass to `npm ci`.
      npmInstallFlags ? [ ],
      # Custom npmInstallHook
      npmInstallHook ? null,
      # Flags to pass to `npm pack`.
      npmPackFlags ? [ ],
      # Flags to pass to `npm prune`.
      npmPruneFlags ? npmInstallFlags,
      # Flags to pass to `npm rebuild`.
      npmRebuildFlags ? [ ],
      # Value for npm `--workspace` flag and directory in which the files to be installed are found.
      npmWorkspace ? null,
      patchFlags ? [ ],
      patches ? [ ],
      postPatch ? "",
      prePatch ? "",
      sourceRoot ? null,
      src ? null,
      srcs ? null,
      ...
    }@args:

    let
      # .override {} negates splicing, so we need to use buildPackages explicitly
      npmHooks = buildPackages.npmHooks.override {
        inherit nodejs;
      };
    in
    {
      inherit npmDeps npmBuildScript;
      strictDeps = true;

      nativeBuildInputs =
        nativeBuildInputs
        ++ [
          nodejs
          # Prefer passed hooks
          (if npmConfigHook != null then npmConfigHook else npmHooks.npmConfigHook)
          (if npmBuildHook != null then npmBuildHook else npmHooks.npmBuildHook)
          (if npmInstallHook != null then npmInstallHook else npmHooks.npmInstallHook)
          nodejs.python
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [ cctools ];

      buildInputs = buildInputs ++ [ nodejs ];

      env = (args.env or { }) // {
        NIX_NPM_FETCHER_VERSION = npmDepsFetcherVersion;
      };

      # Stripping takes way too long with the amount of files required by a typical Node.js project.
      dontStrip = args.dontStrip or true;

      meta = (args.meta or { }) // {
        platforms = args.meta.platforms or nodejs.meta.platforms;
      };
    };
}
