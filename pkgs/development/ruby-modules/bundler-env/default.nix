{
  lib,
  buildEnv,
  buildPackages,
  bundler,
  callPackage,
  defaultGemConfig,
  ruby,
  runCommand,
}@defs:

{
  copyGemFiles ? false, # Copy gem files instead of symlinking
  document ? [ ],
  gemConfig ? defaultGemConfig,
  gemdir ? null,
  gemfile ? null,
  gemset ? null,
  groups ? [ "default" ],
  ignoreCollisions ? false,
  lockfile ? null,
  meta ? { },
  name ? null,
  passthru ? { },
  pname ? null,
  postBuild ? null,
  ruby ? defs.ruby,
  ...
}@args:

let
  inherit
    (import ../bundled-common/functions.nix {
      inherit
        lib
        ruby
        gemConfig
        groups
        ;
    })
    genStubsScript
    ;

  basicEnv = (callPackage ../bundled-common { inherit bundler; }) (
    args
    // {
      inherit pname name;
      mainGemName = pname;
    }
  );

  inherit (basicEnv) envPaths;
  # Idea here is a mkDerivation that gen-bin-stubs new stubs "as specified" -
  # either specific executables or the bin/ for certain gem(s), but
  # incorporates the basicEnv as a requirement so that its $out is in our path.

  # When stubbing the bins for a gem, we should use the gem expression
  # directly, which means that basicEnv should somehow make it available.

  # Different use cases should use different variations on this file, rather
  # than the expression trying to deduce a use case.

in
# The basicEnv should be put into passthru so that e.g. nix-shell can use it.
if pname == null then
  basicEnv // { inherit name basicEnv; }
else
  let
    bundlerEnvArgs = {
      inherit ignoreCollisions;
      inherit (basicEnv) pname version;

      postBuild =
        genStubsScript {
          inherit
            lib
            runCommand
            ruby
            bundler
            groups
            ;

          binPaths = [ basicEnv.gems.${pname} ];
          confFiles = basicEnv.confFiles;
        }
        + lib.optionalString (postBuild != null) postBuild;

      paths = envPaths;
      pathsToLink = [ "/lib" ];

      passthru =
        basicEnv.passthru
        // {
          inherit basicEnv;
          inherit (basicEnv) env;
        }
        // passthru;

      meta = {
        platforms = ruby.meta.platforms;
      }
      // meta;
    };
  in
  if copyGemFiles then
    runCommand basicEnv.name (bundlerEnvArgs // { __structuredAttrs = true; }) ''
      mkdir -p $out
      for i in $paths; do
        ${buildPackages.rsync}/bin/rsync -a $i/lib $out/
      done
      eval "$postBuild"
    ''
  else
    buildEnv bundlerEnvArgs
