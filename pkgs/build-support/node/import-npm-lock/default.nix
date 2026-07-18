{
  lib,
  stdenv,
  fetchurl,
  callPackages,
  cctools,
  runCommand,
}:

let
  inherit (builtins)
    match
    elemAt
    toJSON
    toFile
    removeAttrs
    ;
  inherit (lib) importJSON mapAttrs;

  matchGitHubReference = match "github(.com)?:.+";
  getName = package: package.name or "unknown";
  getVersion = package: package.version or "0.0.0";

  # Fetch a module from package-lock.json -> packages
  fetchModule =
    {
      fetcherOpts,
      module,
      npmRoot ? null,
    }:
    (
      if module ? "resolved" && module.resolved != null then
        (
          let
            # Parse scheme from URL
            mUrl = match "(.+)://(.+)" module.resolved;
            scheme = elemAt mUrl 0;
          in
          (
            if mUrl == null then
              (
                assert npmRoot != null;
                {
                  outPath = npmRoot + "/${module.resolved}";
                }
              )
            else if (scheme == "http" || scheme == "https") then
              (fetchurl (
                {
                  hash = module.integrity;
                  url = module.resolved;
                }
                // fetcherOpts
              ))
            else if lib.hasPrefix "git" module.resolved then
              let
                url = elemAt mUrl 1;
                urlParts = lib.splitString "#" url;
                commit = if builtins.length urlParts == 2 then elemAt urlParts 1 else null;
              in
              (fetchGit (
                {
                  url = "${scheme}://${elemAt urlParts 0}";
                }
                // lib.optionalAttrs (commit != null) {
                  rev = commit;
                }
                // fetcherOpts
              ))
            else
              throw "Unsupported URL scheme: ${scheme}"
          )
        )
      else
        null
    );

  cleanModule = lib.flip removeAttrs [
    "link" # Remove link not to symlink directories. These have been processed to store paths already.
    "funding" # Remove funding to get rid sponsorship nag in build output
  ];

  # Manage node_modules outside of the store with hooks
  hooks = callPackages ./hooks { };

in
lib.fix (self: {
  inherit hooks;
  inherit (hooks) npmConfigHook linkNodeModulesHook;
  __functor = self: self.importNpmLock;

  # Build node modules from package.json & package-lock.json
  buildNodeModules =
    {
      nodejs,
      derivationArgs ? { },
      npmRoot ? null,
      package ? importJSON (npmRoot + "/package.json"),
      packageLock ? importJSON (npmRoot + "/package-lock.json"),
    }:
    let
      # Backwards compatibility: if derivationArgs contains passAsFile,
      # we can't force structuredAttrs here yet.
      __structuredAttrs = !(derivationArgs ? passAsFile);
    in
    stdenv.mkDerivation (
      {
        pname = derivationArgs.pname or "${getName package}-node-modules";
        version = derivationArgs.version or getVersion package;

        installPhase = ''
          runHook preInstall
          mkdir $out
          cp package.json $out/
          cp package-lock.json $out/
          [[ -d node_modules ]] && mv node_modules $out/
          runHook postInstall
        '';

        dontUnpack = true;

        npmDeps = self.importNpmLock {
          inherit npmRoot package packageLock;
        };

        package = toJSON package;
        packageLock = toJSON packageLock;
      }
      // derivationArgs
      // {
        inherit __structuredAttrs;

        postPatch =
          (
            if __structuredAttrs then
              ''
                printf "%s" "$package" > package.json
                printf "%s" "$packageLock" > package-lock.json
              ''
            else
              ''
                cp --no-preserve=mode "$packagePath" package.json
                cp --no-preserve=mode "$packageLockPath" package-lock.json
              ''
          )
          + derivationArgs.postPatch or "";

        nativeBuildInputs = [
          nodejs
          nodejs.passthru.python
          hooks.npmConfigHook
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [ cctools ]
        ++ derivationArgs.nativeBuildInputs or [ ];
      }
      // lib.optionalAttrs (!__structuredAttrs) {
        passAsFile = [
          "package"
          "packageLock"
        ]
        ++ derivationArgs.passAsFile;
      }
    );

  importNpmLock =
    {
      # A map of additional fetcher options forwarded to the fetcher used to download the package.
      # Example: { "node_modules/axios" = { curlOptsList = [ "--verbose" ]; }; }
      # This will download the axios package with curl's verbose option.
      fetcherOpts ? { },
      npmRoot ? null,
      package ? importJSON (npmRoot + "/package.json"),
      packageLock ? importJSON (npmRoot + "/package-lock.json"),
      # A map from node_module path to an alternative package to use instead of fetching the source in package-lock.json.
      # Example: { "node_modules/axios" = stdenv.mkDerivation { ... }; }
      # This is useful if you want to inject custom sources for a specific package.
      packageSourceOverrides ? { },
      pname ? getName package,
      version ? getVersion package,
    }:
    let
      mapLockDependencies = mapAttrs (
        name: version:
        (
          # Substitute the constraint with the version of the dependency from the top-level of package-lock.
          if
            (
              # if the version is `latest`
              version == "latest"
              ||
                # Or if it's a github reference
                matchGitHubReference version != null
            )
          then
            packageLock'.packages.${"node_modules/${name}"}.version
          # But not a regular version constraint
          else
            version
        )
      );

      packageLock' = packageLock // {
        packages = mapAttrs (
          modulePath: module:
          let
            src =
              packageSourceOverrides.${modulePath} or (fetchModule {
                inherit module npmRoot;
                fetcherOpts = fetcherOpts.${modulePath} or { };
              });
          in
          cleanModule module
          // lib.optionalAttrs (src != null) {
            resolved = "file:${src}";
          }
          // lib.optionalAttrs (module ? dependencies) {
            dependencies = mapLockDependencies module.dependencies;
          }
          // lib.optionalAttrs (module ? optionalDependencies) {
            optionalDependencies = mapLockDependencies module.optionalDependencies;
          }
        ) packageLock.packages;
      };

      mapPackageDependencies = mapAttrs (
        name: _: packageLock'.packages.${"node_modules/${name}"}.resolved
      );

      # Substitute dependency references in package.json with Nix store paths
      packageJSON' =
        package
        // lib.optionalAttrs (package ? dependencies) {
          dependencies = mapPackageDependencies package.dependencies;
        }
        // lib.optionalAttrs (package ? devDependencies) {
          devDependencies = mapPackageDependencies package.devDependencies;
        };

      pname = package.name or "unknown";

    in
    runCommand "${pname}-${version}-sources"
      {
        inherit pname version;
        __structuredAttrs = true;
        package = toJSON packageJSON';
        packageLock = toJSON packageLock';
      }
      ''
        mkdir $out
        printf "%s" "$package" > $out/package.json
        printf "%s" "$packageLock" > $out/package-lock.json
      '';
})
