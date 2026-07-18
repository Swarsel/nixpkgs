{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  meta,
  ruby,
  stdenvNoCC,
  writeText,
  licenseAccepted ? false,
}:

let
  # Coerces a string to an int.
  coerceInt = val: if lib.isInt val then val else lib.toIntBase10 val;

  coerceIntVersion = v: coerceInt (lib.versions.major (toString v));

  # Parses a single version, substituting "latest" with the latest version.
  parseVersion =
    repo: key: version:
    if version == "latest" then repo.latest.${key} else version;

  # Parses a list of versions, substituting "latest" with the latest version.
  parseVersions =
    repo: key: versions:
    lib.sort (a: b: lib.strings.compareVersions (toString a) (toString b) > 0) (
      lib.unique (map (parseVersion repo key) versions)
    );
in
{
  abiVersions ? [
    "x86"
    "x86_64"
    "armeabi-v7a"
    "arm64-v8a"
  ],
  buildToolsVersions ? [ "latest" ],
  cmakeVersions ? [ "latest" ],
  cmdLineToolsVersion ? "latest",
  emulatorVersion ? "latest",
  extraLicenses ? [ ],
  # cmake has precompiles on x86_64 and Darwin platforms. Default to true there for compatibility.
  includeCmake ? stdenv.hostPlatform.isx86_64 || stdenv.hostPlatform.isDarwin,
  includeEmulator ? false,
  includeExtras ? [ ],
  includeNDK ? false,
  includeSources ? false,
  includeSystemImages ? false,
  maxPlatformVersion ? "latest",
  minPlatformVersion ? null,
  ndkVersion ? "latest",
  ndkVersions ? [ ndkVersion ],
  numLatestPlatformVersions ? 1,
  platformToolsVersion ? "latest",
  platformVersions ?
    if minPlatformVersion != null && maxPlatformVersion != null then
      # Range between min and max, inclusive.
      let
        minPlatformVersion' = parseVersion repo "platforms" minPlatformVersion;
        maxPlatformVersion' = parseVersion repo "platforms" maxPlatformVersion;
        minPlatformVersionInt = coerceIntVersion minPlatformVersion';
        maxPlatformVersionInt = coerceIntVersion maxPlatformVersion';
        range = lib.range (lib.min minPlatformVersionInt maxPlatformVersionInt) (
          lib.max minPlatformVersionInt maxPlatformVersionInt
        );
      in
      # Don't use the actual latest version in lieu of the rounded version here,
      # since when Google upgrades it would have the nasty side effect of being
      # unstable and picking 35 -> 36 -> 37 instead of 35 -> 36.1 -> 37.
      # Best to stay consistent.
      #
      # However, if only one platform is requested and it's the latest (which is the default),
      # we should use it.
      if lib.length range == 1 then lib.singleton maxPlatformVersion' else range
    else
      # Use numLatestPlatformVersions with a lower cutoff of minPlatformVersion (defaulting to 1)
      # to determine how many of the latest *major* versions we should pick.
      let
        minPlatformVersionInt =
          if minPlatformVersion == null then
            1
          else
            coerceIntVersion (parseVersion repo "platforms" minPlatformVersion);
        latestPlatformVersionInt = lib.max minPlatformVersionInt (coerceIntVersion repo.latest.platforms);
        firstPlatformVersionInt = lib.max minPlatformVersionInt (
          latestPlatformVersionInt - (lib.max 1 numLatestPlatformVersions) + 1
        );
        range = lib.range firstPlatformVersionInt latestPlatformVersionInt;
      in
      # Ditto, see above.
      if lib.length range == 1 then lib.singleton repo.latest.platforms else range,
  repo ? (
    # Reads the repo JSON. If repoXmls is provided, will build a repo JSON into the Nix store.
    if repoXmls != null then
      let
        # Uses update.rb to create a repo spec.
        mkRepoJson =
          {
            addons ? [ ],
            images ? [ ],
            packages ? [ ],
          }:
          let
            mkRepoRuby = (
              ruby.withPackages (
                pkgs: with pkgs; [
                  slop
                  curb
                  nokogiri
                ]
              )
            );
            mkRepoRubyArguments = lib.lists.flatten [
              (map (package: [
                "--packages"
                "${package}"
              ]) packages)
              (map (image: [
                "--images"
                "${image}"
              ]) images)
              (map (addon: [
                "--addons"
                "${addon}"
              ]) addons)
            ];
          in
          stdenvNoCC.mkDerivation {
            buildInputs = [ mkRepoRuby ];

            buildPhase = ''
              env ruby -e 'load "${./update.rb}"' -- ${lib.escapeShellArgs mkRepoRubyArguments} --input /dev/null --output repo.json
            '';

            installPhase = ''
              mv repo.json $out
            '';

            name = "androidenv-repo-json";
            preferLocalBuild = true;
            unpackPhase = "true";
          };
        repoXmlSpec = {
          addons = repoXmls.addons or [ ];
          images = repoXmls.images or [ ];
          packages = repoXmls.packages or [ ];
        };
      in
      lib.importJSON "${mkRepoJson repoXmlSpec}"
    else
      lib.importJSON repoJson
  ),
  repoJson ? ./repo.json,
  repoXmls ? null,
  systemImageTypes ? [
    "google_apis"
    "google_apis_playstore"
  ],
  toolsVersion ? "latest",
  useGoogleAPIs ? false,
  useGoogleTVAddOns ? false,
}:

let
  # Resolve all the platform versions.
  platformVersions' = parseVersions repo "platforms" platformVersions;

  # Determine the Android os identifier from Nix's system identifier
  os =
    {
      aarch64-darwin = "macosx";
      aarch64-linux = "linux";
      x86_64-linux = "linux";
    }
    .${stdenv.hostPlatform.system} or "all";

  # Determine the Android arch identifier from Nix's system identifier
  arch =
    {
      aarch64-darwin = "aarch64";
      aarch64-linux = "aarch64";
      x86_64-linux = "x64";
    }
    .${stdenv.hostPlatform.system} or "all";

  # Converts all 'archives' keys in a repo spec to fetchurl calls.
  fetchArchives =
    attrSet:
    lib.attrsets.mapAttrsRecursive (
      path: value:
      if (builtins.elemAt path (builtins.length path - 1)) == "archives" then
        let
          validArchives = builtins.filter (
            archive:
            let
              isTargetOs =
                if builtins.hasAttr "os" archive then archive.os == os || archive.os == "all" else true;
              isTargetArch =
                if builtins.hasAttr "arch" archive then archive.arch == arch || archive.arch == "all" else true;
            in
            isTargetOs && isTargetArch
          ) value;
          packageInfo = lib.attrByPath (lib.sublist 0 (builtins.length path - 1) path) null attrSet;
        in
        lib.optionals (builtins.length validArchives > 0) (
          lib.last (
            map (
              archive:
              (fetchurl {
                inherit (archive) url sha1;
                inherit meta;
                pname = packageInfo.name;
                version = packageInfo.revision;

                passthru = {
                  info = packageInfo;
                };
              }).overrideAttrs
                (
                  finalAttrs: previousAttrs: {
                    # fetchurl prioritize `pname` and `version` over the specified `name`,
                    # so specify custom `name` in an override.
                    name = baseNameOf (lib.head (finalAttrs.urls));
                  }
                )
            ) validArchives
          )
        )
      else
        value
    ) attrSet;

  # Converts the repo attrset into fetch calls.
  allArchives = {
    addons = fetchArchives repo.addons;
    extras = fetchArchives repo.extras;
    packages = fetchArchives repo.packages;
    system-images = fetchArchives repo.images;
  };

  # Lift the archives to the package level for easy search,
  # and add recurseIntoAttrs to all of them.
  allPackages =
    let
      liftedArchives = lib.attrsets.mapAttrsRecursiveCond (value: !(builtins.hasAttr "archives" value)) (
        path: value:
        if (value.archives or null) != null && (value.archives or [ ]) != [ ] then
          lib.dontRecurseIntoAttrs value.archives
        else
          null
      ) allArchives;

      # Creates a version key from a name.
      # Converts things like 'extras;google;auto' to 'extras-google-auto'
      toVersionKey =
        name:
        let
          normalizedName = lib.replaceStrings [ ";" "." ] [ "-" "_" ] name;
          versionParts = lib.match "^([0-9][0-9\\.]*)(.*)$" normalizedName;
        in
        if versionParts == null then normalizedName else "v" + lib.concatStrings versionParts;

      recurse = lib.mapAttrs' (
        name: value:
        if builtins.isAttrs value && (value.recurseForDerivations or true) then
          lib.nameValuePair (toVersionKey name) (lib.recurseIntoAttrs (recurse value))
        else
          lib.nameValuePair (toVersionKey name) value
      );
    in
    lib.recurseIntoAttrs (recurse liftedArchives);

  # Converts a license name to a list of license texts.
  mkLicenses = licenseName: repo.licenses.${licenseName};

  # Converts a list of license names to a flattened list of license texts.
  # Just used for displaying licenses.
  mkLicenseTexts =
    licenseNames:
    lib.lists.flatten (
      map (
        licenseName: map (licenseText: "--- ${licenseName} ---\n${licenseText}") (mkLicenses licenseName)
      ) licenseNames
    );

  # Converts a license name to a list of license hashes.
  mkLicenseHashes =
    licenseName: map (licenseText: builtins.hashString "sha1" licenseText) (mkLicenses licenseName);

  # The list of all license names we're accepting. Put android-sdk-license there
  # by default.
  licenseNames = lib.lists.unique (
    [
      "android-sdk-license"
    ]
    ++ extraLicenses
  );

  # Returns true if the given version exists.
  hasVersion =
    packages: package: version:
    lib.hasAttrByPath [ package (toString version) ] packages
    || lib.hasAttrByPath [ package "${(toString version)}.0" ] packages;

  # Displays a nice error message that includes the available options if a version doesn't exist.
  # Note that allPackages can be a list of package sets, or a single package set. Pass a list if
  # you want to prioritize elements to the left (e.g. for passing a platform major version).
  checkVersion =
    allPackages: package: version:
    let
      # Convert the package sets to a list.
      allPackages' = if lib.isList allPackages then allPackages else lib.singleton allPackages;

      # Pick the first package set where we have the version.
      packageSet = lib.findFirst (packages: hasVersion packages package version) null allPackages';
    in
    if packageSet == null then
      throw ''
        The version ${toString version} is missing in package ${package}.
        The only available versions are ${
          lib.concatStringsSep ", " (
            lib.attrNames (lib.foldl (s: x: s // (x.${package} or { })) { } allPackages')
          )
        }.
      ''
    else
      packageSet.${package}.${toString version} or packageSet.${package}."${toString version}.0";

  # Returns true if we should link the specified plugins.
  shouldLink =
    check: packages:
    assert builtins.isList packages;
    if check == true then
      true
    else if check == false then
      false
    else if check == "if-supported" then
      let
        hasSrc =
          package: package.src != null && (builtins.isList package.src -> builtins.length package.src > 0);
      in
      packages != [ ] && lib.all hasSrc packages
    else
      throw "Invalid argument ${toString check}; use true, false, or if-supported";

  # Function that automatically links all plugins for which multiple versions can coexist
  linkPlugins =
    {
      name,
      plugins,
      check ? true,
    }:
    lib.optionalString (shouldLink check plugins) ''
      mkdir -p ${name}
      ${lib.concatMapStrings (plugin: ''
        ln -s ${plugin}/libexec/android-sdk/${name}/* ${name}
      '') plugins}
    '';

  # Function that automatically links all NDK plugins.
  linkNdkPlugins =
    {
      name,
      plugins,
      check ? true,
      rootName ? name,
    }:
    lib.optionalString (shouldLink check plugins) ''
      mkdir -p ${rootName}
      ${lib.concatMapStrings (plugin: ''
        ln -s ${plugin}/libexec/android-sdk/${name} ${rootName}/${plugin.version}
      '') plugins}
    '';

  # Function that automatically links the default NDK plugin.
  linkNdkPlugin =
    {
      check,
      name,
      plugin,
    }:
    lib.optionalString (shouldLink check [ plugin ]) ''
      ln -s ${plugin}/libexec/android-sdk/${name} ${name}
    '';

  # Function that automatically links a plugin for which only one version exists
  linkPlugin =
    {
      name,
      plugin,
      check ? true,
    }:
    lib.optionalString (shouldLink check [ plugin ]) ''
      ln -s ${plugin}/libexec/android-sdk/${name} ${name}
    '';

  linkSystemImages =
    { check, images }:
    lib.optionalString (shouldLink check images) ''
      mkdir -p system-images
      ${lib.concatMapStrings (system-image: ''
        apiVersion=$(basename $(echo ${system-image}/libexec/android-sdk/system-images/*))
        type=$(basename $(echo ${system-image}/libexec/android-sdk/system-images/*/*))
        mkdir -p system-images/$apiVersion
        ln -s ${system-image}/libexec/android-sdk/system-images/$apiVersion/$type system-images/$apiVersion/$type
      '') images}
    '';

  # Links all plugins related to a requested platform
  linkPlatformPlugins =
    {
      check,
      name,
      plugins,
    }:
    lib.optionalString (shouldLink check plugins) ''
      mkdir -p ${name}
      ${lib.concatMapStrings (plugin: ''
        ln -s ${plugin}/libexec/android-sdk/${name}/* ${name}
      '') plugins}
    ''; # */

in
lib.recurseIntoAttrs rec {
  all = allPackages;

  # This derivation deploys the tools package and symlinks all the desired
  # plugins that we want to use. If the license isn't accepted, prints all the licenses
  # requested and throws.
  androidsdk = callPackage ./cmdline-tools.nix {
    inherit
      deployAndroidPackage
      os
      arch
      meta
      ;

    postInstall =
      if !licenseAccepted then
        throw ''
          ${builtins.concatStringsSep "\n\n" (mkLicenseTexts licenseNames)}

          You must accept the following licenses:
          ${lib.concatMapStringsSep "\n" (str: "  - ${str}") licenseNames}

          a)
            by setting nixpkgs config option 'android_sdk.accept_license = true;'.
          b)
            by an environment variable for a single invocation of the nix tools.
              $ export NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1
        ''
      else
        ''
          # Symlink all requested plugins
          ${linkPlugin {
            name = "platform-tools";
            plugin = platform-tools;
          }}
          ${linkPlugin {
            check = toolsVersion != null;
            name = "tools";
            plugin = tools;
          }}
          ${linkPlugins {
            name = "build-tools";
            plugins = build-tools;
          }}
          ${linkPlugin {
            check = includeEmulator;
            name = "emulator";
            plugin = emulator;
          }}
          ${linkPlugins {
            name = "platforms";
            plugins = platforms;
          }}
          ${linkPlatformPlugins {
            check = includeSources;
            name = "sources";
            plugins = sources;
          }}
          ${linkPlugins {
            check = includeCmake;
            name = "cmake";
            plugins = cmake;
          }}
          ${linkNdkPlugins {
            check = includeNDK;
            name = "ndk-bundle";
            plugins = ndk-bundles;
            rootName = "ndk";
          }}
          ${linkNdkPlugin {
            check = includeNDK;
            name = "ndk-bundle";
            plugin = ndk-bundle;
          }}
          ${linkSystemImages {
            check = includeSystemImages;
            images = system-images;
          }}
          ${linkPlatformPlugins {
            check = useGoogleAPIs;
            name = "add-ons";
            plugins = google-apis;
          }}
          ${linkPlatformPlugins {
            check = useGoogleTVAddOns;
            name = "add-ons";
            plugins = google-tv-addons;
          }}

          # Link extras
          ${lib.concatMapStrings (
            identifier:
            let
              package = allArchives.extras.${identifier};
              path = package.path;
              extras = callPackage ./extras.nix {
                inherit
                  deployAndroidPackage
                  package
                  os
                  arch
                  meta
                  ;
              };
            in
            ''
              targetDir=$(dirname ${path})
              mkdir -p $targetDir
              ln -s ${extras}/libexec/android-sdk/${path} $targetDir
            ''
          ) includeExtras}

          # Expose common executables in bin/
          mkdir -p $out/bin

          for i in ${platform-tools}/bin/*; do
              ln -s $i $out/bin
          done

          ${lib.optionalString (shouldLink includeEmulator [ emulator ]) ''
            for i in ${emulator}/bin/*; do
                ln -s $i $out/bin
            done
          ''}

          find "$ANDROID_HOME/${cmdline-tools-package.path}/bin" -type f -executable | while read i; do
              ln -s $i $out/bin
          done

          # Write licenses
          mkdir -p licenses
          ${lib.concatMapStrings (
            licenseName:
            let
              licenseHashes = builtins.concatStringsSep "\n" (mkLicenseHashes licenseName);
              licenseHashFile = writeText "androidenv-${licenseName}" licenseHashes;
            in
            ''
              ln -s ${licenseHashFile} licenses/${licenseName}
            ''
          ) licenseNames}
        '';

    package = cmdline-tools-package;
  };

  build-tools = map (
    version:
    callPackage ./build-tools.nix {
      inherit
        deployAndroidPackage
        os
        arch
        meta
        ;

      postInstall = ''
        ${linkPlugin {
          check = toolsVersion != null;
          name = "tools";
          plugin = tools;
        }}
      '';

      package = checkVersion allArchives.packages "build-tools" version;
    }
  ) (parseVersions repo "build-tools" buildToolsVersions);

  cmake = map (
    version:
    callPackage ./cmake.nix {
      inherit
        deployAndroidPackage
        os
        arch
        meta
        ;

      package = checkVersion allArchives.packages "cmake" version;
    }
  ) (parseVersions repo "cmake" cmakeVersions);

  cmdline-tools-package = checkVersion allArchives.packages "cmdline-tools" (
    parseVersion repo "cmdline-tools" cmdLineToolsVersion
  );

  deployAndroidPackage = (
    {
      package,
      buildInputs ? [ ],
      meta ? { },
      patchInstructions ? "",
      ...
    }@args:
    let
      extraParams = removeAttrs args [
        "package"
        "os"
        "arch"
        "buildInputs"
        "patchInstructions"
      ];
    in
    deployAndroidPackages (
      {
        inherit buildInputs;
        packages = [ package ];

        patchesInstructions = {
          "${package.name}" = patchInstructions;
        };
      }
      // extraParams
    )
  );

  deployAndroidPackages = callPackage ./deploy-androidpackages.nix {
    inherit
      stdenv
      lib
      mkLicenses
      meta
      os
      arch
      ;
  };

  emulator = callPackage ./emulator.nix {
    inherit
      deployAndroidPackage
      os
      arch
      meta
      ;

    postInstall = ''
      ${linkSystemImages {
        check = includeSystemImages;
        images = system-images;
      }}
    '';

    package = checkVersion allArchives.packages "emulator" (
      parseVersion repo "emulator" emulatorVersion
    );
  };

  # Makes a Google API bundle from supported versions.
  google-apis = map (
    version:
    deployAndroidPackage {
      package = (checkVersion allArchives "addons" version).google_apis;
    }
  ) (lib.filter (hasVersion allArchives "addons") platformVersions');

  # Makes a Google TV addons bundle from supported versions.
  google-tv-addons = map (
    version:
    deployAndroidPackage {
      package = (checkVersion allArchives "addons" version).google_tv_addon;
    }
  ) (lib.filter (hasVersion allArchives "addons") platformVersions');

  # The "default" NDK bundle.
  ndk-bundle = if ndk-bundles == [ ] then null else lib.head ndk-bundles;

  # All NDK bundles.
  ndk-bundles =
    let
      # Creates a NDK bundle.
      makeNdkBundle =
        package:
        callPackage ./ndk-bundle {
          inherit
            deployAndroidPackage
            os
            arch
            platform-tools
            meta
            package
            ;
        };
    in
    lib.flatten (
      map (
        version:
        let
          package = makeNdkBundle (
            allArchives.packages.ndk-bundle.${version} or allArchives.packages.ndk.${version}
          );
        in
        lib.optional (shouldLink includeNDK [ package ]) package
      ) (parseVersions repo "ndk" ndkVersions)
    );

  platform-tools = callPackage ./platform-tools.nix {
    inherit
      deployAndroidPackage
      os
      arch
      meta
      ;

    package = checkVersion allArchives.packages "platform-tools" (
      parseVersion repo "platform-tools" platformToolsVersion
    );
  };

  # This is a list of the chosen API levels, as integers.
  platformVersions = platformVersions';

  platforms = map (
    version:
    deployAndroidPackage {
      package = checkVersion allArchives.packages "platforms" version;
    }
  ) platformVersions';

  # Google is not including sources for API 37+. If the user requests them, don't fail.
  sources = lib.filter (source: source != null) (
    map (
      version:
      let
        package =
          let
            version' = builtins.tryEval (checkVersion allArchives.packages "sources" version);
          in
          if version'.success then version'.value else null;
      in
      if package == null then
        null
      else
        deployAndroidPackage {
          inherit package;
        }
    ) platformVersions'
  );

  system-images = lib.flatten (
    map (
      apiVersion:
      map (
        type:
        # Deploy all system images with the same  systemImageType in one derivation to avoid the `null` problem below
        # with avdmanager when trying to create an avd!
        #
        # ```
        # $ yes "" | avdmanager create avd --force --name testAVD --package 'system-images;android-33;google_apis;x86_64'
        # Error: Package path is not valid. Valid system image paths are:
        # null
        # ```
        let
          availablePackages =
            map (abiVersion: allArchives.system-images.${toString apiVersion}.${type}.${abiVersion})
              (
                builtins.filter (
                  abiVersion: lib.hasAttrByPath [ (toString apiVersion) type abiVersion ] allArchives.system-images
                ) abiVersions
              );

          instructions = lib.listToAttrs (
            map (package: {
              name = package.name;

              value = lib.optionalString (lib.hasPrefix "google_apis" type) ''
                # Patch 'google_apis' system images so they're recognized by the sdk.
                # Without this, `android list targets` shows 'Tag/ABIs : no ABIs' instead
                # of 'Tag/ABIs : google_apis*/*' and the emulator fails with an ABI-related error.
                sed -i '/^Addon.Vendor/d' source.properties
              '';
            }) availablePackages
          );
        in
        lib.optionals (availablePackages != [ ]) (deployAndroidPackages {
          packages = availablePackages;
          patchesInstructions = instructions;
        })
      ) systemImageTypes
    ) platformVersions'
  );

  tools = callPackage ./tools.nix {
    inherit
      deployAndroidPackage
      os
      arch
      meta
      ;

    postInstall = ''
      ${linkPlugin {
        name = "platform-tools";
        plugin = platform-tools;
      }}
      ${linkPlugin {
        check = includeEmulator;
        name = "emulator";
        plugin = emulator;
      }}
    '';

    package = checkVersion allArchives.packages "tools" (parseVersion repo "tools" toolsVersion);
  };
}
