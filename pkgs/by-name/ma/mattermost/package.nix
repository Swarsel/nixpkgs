{
  lib,
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  callPackage,
  fetchNpmDeps,
  jq,
  nix-update-script,
  nixosTests,
  nodejs,
  npm-lockfile-fix,
  stdenvNoCC,
  latestVersionInfo ? null,
  removeFreeBadge ? false,
  removeUserLimit ? false,
  versionInfo ? {
    version = "11.7.6";
    vendorHash = "sha256-XaXqQN20c3DhW2/L0zhTA8dLeRp4MyBxUKpiMVwp/7s=";
    npmDepsHash = "sha256-F7o+AVM1WiuHKDQaqHbxDjWT1vAiddh4/D8EktxncAs=";
    # ESR releases only. Note: if NixOS would release with an ESR that goes out
    # of support during the lifetime of the NixOS release, it is acceptable
    # to put the latest non-ESR release here if we change it to an ESR shortly after
    # the NixOS release.
    #
    # See <https://docs.mattermost.com/upgrade/extended-support-release.html>.
    # When a new ESR version is available (e.g. 8.1.x -> 9.5.x), update
    # the version regex here as well.
    #
    # Ensure you also check ../mattermostLatest/package.nix.
    regex = "^v(11\\.7\\.[0-9]+)$";
    srcHash = "sha256-oMjfSX45+sEQwNpNVDTOlCBUK7OSBCCKpaUMMrRzdQM=";
  },
  ...
}:

assert lib.warnIf (latestVersionInfo != null && (removeUserLimit || removeFreeBadge)) ''
  The user limit and free badge patches are not tested with this Mattermost version
  (${latestVersionInfo.version}).
'' true;

let
  /*
    Helper function that sets the `withTests` and `withoutTests` passthru correctly,
    and returns the version with tests.

    The primary reason to use this helper over reindenting the whole file is to avoid
    lots of manual backporting when the update script runs.
  */
  buildMattermost =
    { passthru, ... }@args:
    let
      # Joins the webapp and Matermost derivation together.
      # That way patches to the webapp won't cause a rebuild of the server.
      wrapMattermost =
        server:
        stdenvNoCC.mkDerivation {
          inherit server;

          # src and npmDeps must be provided for the update script!
          inherit (server)
            pname
            version
            src
            goModules
            npmDeps
            webapp
            meta
            ;

          # Just link all the server and webapp root directories together.
          installPhase = ''
            mkdir -p $out
            for dir in "$server" "$webapp"; do
              for path in "$dir"/*; do
                ln -s "$path" "$out/$(basename -- "$path")"
              done
            done
          '';

          dontUnpack = true;
          passthru = finalPassthru;
        };
      finalPassthru =
        let
          withoutTestsUnwrapped = buildGoModule (args // { passthru = finalPassthru; });
          withTestsUnwrapped = callPackage ./tests.nix { mattermost = withoutTestsUnwrapped; };
        in
        lib.recursiveUpdate passthru rec {
          tests.mattermostWithTests = withTests;
          withTests = wrapMattermost withTestsUnwrapped;
          withoutTests = wrapMattermost withoutTestsUnwrapped;
        };
    in
    finalPassthru.withoutTests;

  versionInfo' =
    if
      latestVersionInfo != null && lib.versionAtLeast latestVersionInfo.version versionInfo.version
    then
      # Prefer the latest if we're building mattermostLatest
      latestVersionInfo
    else
      # Prefer the one we have
      assert versionInfo != null;
      versionInfo;
in
buildMattermost rec {
  inherit (versionInfo') version;
  inherit (versionInfo') vendorHash;
  pname = "mattermost";

  src = fetchFromGitHub {
    owner = "mattermost";
    repo = "mattermost";
    tag = "v${version}";
    hash = versionInfo'.srcHash;

    postFetch = ''
      cd $out/webapp

      # Remove "+..." suffixes on versions.
      ${lib.getExe jq} '
        def desuffix(version): version | gsub("^(?<prefix>[^\\+]+)\\+.*$"; "\(.prefix)");
        .packages |= map_values(if has("version") then .version = desuffix(.version) else . end)
      ' < package-lock.json > package-lock.fixed.json

      # Run the lockfile overlay, if present.
      ${lib.optionalString (versionInfo'.lockfileOverlay or null != null) ''
        ${lib.getExe jq} ${lib.escapeShellArg ''
          # Unlock a dependency and let npm-lockfile-fix relock it.
          def unlock(root; dependency; path):
            root | .packages[path] |= del(.resolved, .integrity)
                 | .packages[path].version = root.packages.channels.dependencies[dependency];
          ${versionInfo'.lockfileOverlay}
        ''} < package-lock.fixed.json > package-lock.overlaid.json
        mv package-lock.overlaid.json package-lock.fixed.json
      ''}
      ${lib.getExe npm-lockfile-fix} package-lock.fixed.json

      rm -f package-lock.json
      mv package-lock.fixed.json package-lock.json
    '';
  };

  patches = lib.optionals removeUserLimit [
    ./mattermost-remove-user-limit.patch
  ];

  preBuild = ''
    make setup-go-work
  '';

  postInstall = ''
    shopt -s extglob
    mkdir -p $out/{i18n,fonts,templates,config}

    # Copy the language packs.
    cp -a $src/server/i18n/* $out/i18n/

    # Fonts have the execute bit set, remove it.
    cp --no-preserve=mode $src/server/fonts/* $out/fonts/

    # Don't copy the Makefile.
    cp -a $src/server/templates/!(Makefile) $out/templates/

    # Generate the config.
    OUTPUT_CONFIG=$out/config/config.json \
      go run -tags production ./scripts/config_generator
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    for subPackage in $subPackages; do
      echo "Checking version for: $subPackage" >&2
      "$out/bin/$(basename -- "$subPackage")" version | grep "$version"
    done

    runHook postInstallCheck
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/mattermost/mattermost/server/public/model.Version=${version}"
    "-X github.com/mattermost/mattermost/server/public/model.BuildNumber=${version}-nixpkgs"
    "-X github.com/mattermost/mattermost/server/public/model.BuildDate=1970-01-01"
    "-X github.com/mattermost/mattermost/server/public/model.BuildHash=v${version}"
    "-X github.com/mattermost/mattermost/server/public/model.BuildHashEnterprise=none"
    "-X github.com/mattermost/mattermost/server/public/model.BuildEnterpriseReady=false"
  ];

  modRoot = "./server";

  npmDeps = fetchNpmDeps {
    inherit src;
    forceGitDeps = true;
    hash = versionInfo'.npmDepsHash;
    makeCacheWritable = true;
    sourceRoot = "${src.name}/webapp";
  };

  # Needed because buildGoModule does not support go workspaces yet.
  # We use go 1.22's workspace vendor command, which is not yet available
  # in the default version of go used in nixpkgs, nor is it used by upstream:
  # https://github.com/mattermost/mattermost/issues/26221#issuecomment-1945351597
  overrideModAttrs = _: {
    buildPhase = ''
      runHook preBuild

      make setup-go-work
      go work vendor -e -v

      runHook postBuild
    '';
  };

  subPackages = [
    "cmd/mattermost"
    "cmd/mmctl"
  ];

  tags = [ "production" ];

  passthru = {
    # Builds a Mattermost plugin.
    buildPlugin = callPackage ./build-plugin.nix { };
    tests.mattermost = nixosTests.mattermost;

    updateScript = nix-update-script {
      extraArgs = [
        "--use-github-releases"
        "--version-regex"
        versionInfo'.regex
      ]
      ++ lib.optionals (versionInfo'.autoUpdate or null != null) [
        "--override-filename"
        versionInfo'.autoUpdate
      ];
    };

    # Builds the webapp.
    webapp = buildNpmPackage rec {
      inherit version src;
      inherit nodejs;
      pname = "mattermost-webapp";

      patches = lib.optionals removeFreeBadge [
        ./mattermost-remove-free-banner.patch
      ];

      # Remove deprecated image-webpack-loader causing build failures
      # See: https://github.com/tcoopman/image-webpack-loader#deprecated
      postPatch = ''
        substituteInPlace channels/webpack.config.js \
          --replace-fail 'options: {}' 'options: { disable: true }'
      '';

      npmDepsHash = npmDeps.hash;

      buildPhase = ''
        runHook preBuild

        for ws in platform/{types,client,shared,components} channels; do
          if [ -d "$ws" ]; then
            npm run build --workspace="$ws"
          fi
        done

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/client
        cp -a channels/dist/* $out/client

        runHook postInstall
      '';

      forceGitDeps = true;
      makeCacheWritable = true;
      npmRebuildFlags = [ "--ignore-scripts" ];
      sourceRoot = "${src.name}/webapp";
    };
  };

  meta = {
    description = "Open source platform for secure collaboration across the entire software development lifecycle";
    homepage = "https://www.mattermost.org";

    license = with lib.licenses; [
      agpl3Only
      asl20
    ];

    maintainers = with lib.maintainers; [
      ryantm
      numinit
      mgdelacroix
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mattermost";
  };
}
