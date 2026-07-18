{
  lib,
  fetchFromGitHub,
  applyPatches,
  buildDotnetModule,
  dotnetCorePackages,
  fetchYarnDeps,
  fetchpatch,
  fixup-yarn-lock,
  nix,
  nixosTests,
  nodejs,
  prefetch-yarn-deps,
  python3Packages,
  servarr-ffmpeg,
  sqlite,
  stdenvNoCC,
  # update script
  writers,
  yarn,
  withFFmpeg ? true, # replace bundled ffprobe binary with symlink to ffmpeg package.
}:
let
  version = "6.3.0.10514";
  # The dotnet8 compatibility patches also change `yarn.lock`, so we must pass
  # the already patched lockfile to `fetchYarnDeps`.
  src = applyPatches {
    patches = lib.optionals (lib.versionOlder version "6.0") [
      # See https://github.com/Radarr/Radarr/pull/11064
      # Unfortunately, the .NET 8 upgrade will be merged into the v6 branch,
      # and it may take some time for that to become stable.
      # However, the patches cleanly apply to v5 as well.
      (fetchpatch {
        hash = "sha256-3YgQV4xc2i5DNWp2KxVz6M5S8n//a/Js7pckGZ06fWc=";
        name = "dotnet8-compatibility";
        url = "https://github.com/Radarr/Radarr/commit/2235823af313ea1f39fd1189b69a75fc5d380c41.patch";
      })
      (fetchpatch {
        hash = "sha256-SAMUHqlSj8FPq20wY8NWbRytVZXTPtMXMfM3CoM8kSA=";
        name = "dotnet8-darwin-compatibility";
        url = "https://github.com/Radarr/Radarr/commit/2a886fb26a70b4d48a4ad08d7ee23e5e4d81f522.patch";
      })
    ];

    postPatch = ''
      mv src/NuGet.config NuGet.Config
    '';

    src = fetchFromGitHub {
      owner = "Radarr";
      repo = "Radarr";
      tag = "v${version}";
      hash = "sha256-1CAcsqhdAH2dOcOMVyIlaqEmCKDwXNUJf3SuVuJEZ7E=";
    };
  };
  rid = dotnetCorePackages.systemToDotnetRid stdenvNoCC.hostPlatform.system;
in
buildDotnetModule {
  inherit version src;
  pname = "radarr";
  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    yarn
    prefetch-yarn-deps
    fixup-yarn-lock
  ];

  postConfigure = ''
    yarn config --offline set yarn-offline-mirror "$yarnOfflineCache"
    fixup-yarn-lock yarn.lock
    yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs --build node_modules
  '';

  postBuild = ''
    yarn --offline run build --env production
  '';

  doCheck = true;

  postInstall =
    lib.optionalString withFFmpeg ''
      rm -- "$out/lib/radarr/ffprobe"
      ln -s -- "$ffprobe" "$out/lib/radarr/ffprobe"
    ''
    + ''
      cp -a -- _output/UI "$out/lib/radarr/UI"
    '';

  __darwinAllowLocalNetworking = true; # for tests
  __structuredAttrs = true; # for Copyright property that contains spaces

  disabledTests = [
    # setgid tests
    "NzbDrone.Mono.Test.DiskProviderTests.DiskProviderFixture.should_preserve_setgid_on_set_folder_permissions"
    "NzbDrone.Mono.Test.DiskProviderTests.DiskProviderFixture.should_clear_setgid_on_set_folder_permissions"

    # we do not set application data directory during tests (i.e. XDG data directory)
    "NzbDrone.Mono.Test.DiskProviderTests.FreeSpaceFixture.should_return_free_disk_space"
    "NzbDrone.Common.Test.ServiceFactoryFixture.event_handlers_should_be_unique"

    # attempts to read /etc/*release and fails since it does not exist
    "NzbDrone.Mono.Test.EnvironmentInfo.ReleaseFileVersionAdapterFixture.should_get_version_info"

    # fails to start test dummy because it cannot locate .NET runtime for some reason
    "NzbDrone.Common.Test.ProcessProviderFixture.should_be_able_to_start_process"
    "NzbDrone.Common.Test.ProcessProviderFixture.exists_should_find_running_process"
    "NzbDrone.Common.Test.ProcessProviderFixture.kill_all_should_kill_all_process_with_name"
  ]
  ++ lib.optionals stdenvNoCC.buildPlatform.isDarwin [
    # flaky on darwin
    "NzbDrone.Core.Test.NotificationTests.TraktServiceFixture.should_add_collection_movie_if_valid_mediainfo"
    "NzbDrone.Core.Test.NotificationTests.TraktServiceFixture.should_format_audio_channels_to_one_decimal_when_adding_collection_movie"
  ];

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetFlags = [
    "--property:TargetFramework=net8.0"
    "--property:EnableAnalyzers=false"
    "--property:SentryUploadSymbols=false" # Fix Sentry upload failed warnings
    # Override defaults in src/Directory.Build.props that use current time.
    "--property:Copyright=Copyright 2014-2025 radarr.video (GNU General Public v3)"
    "--property:AssemblyVersion=${version}"
    "--property:AssemblyConfiguration=master"
    "--property:RuntimeIdentifier=${rid}"
  ];

  executables = [ "Radarr" ];
  ffprobe = lib.optionalDrvAttr withFFmpeg (lib.getExe' servarr-ffmpeg "ffprobe");
  nugetDeps = ./deps.json;

  projectFile = [
    "src/NzbDrone.Console/Radarr.Console.csproj"
    "src/NzbDrone.Mono/Radarr.Mono.csproj"
  ];

  runtimeDeps = [ sqlite ];

  # Skip manual, integration, automation and platform-dependent tests.
  testFilters = [
    "TestCategory!=ManualTest"
    "TestCategory!=IntegrationTest"
    "TestCategory!=AutomationTest"

    # makes real HTTP requests
    "FullyQualifiedName!~NzbDrone.Core.Test.UpdateTests.UpdatePackageProviderFixture"
  ]
  ++ lib.optionals stdenvNoCC.buildPlatform.isDarwin [
    # fails on macOS
    "FullyQualifiedName!~NzbDrone.Core.Test.Http.HttpProxySettingsProviderFixture"
  ];

  testProjectFile = [
    "src/NzbDrone.Api.Test/Radarr.Api.Test.csproj"
    "src/NzbDrone.Common.Test/Radarr.Common.Test.csproj"
    "src/NzbDrone.Core.Test/Radarr.Core.Test.csproj"
    "src/NzbDrone.Host.Test/Radarr.Host.Test.csproj"
    "src/NzbDrone.Libraries.Test/Radarr.Libraries.Test.csproj"
    "src/NzbDrone.Mono.Test/Radarr.Mono.Test.csproj"
    "src/NzbDrone.Test.Common/Radarr.Test.Common.csproj"
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-FrYvTYSxUDP68a4n0isEaHxRNFL25N3LNQJVFBOLdyE=";
    yarnLock = "${src}/yarn.lock";
  };

  passthru = {
    tests = {
      inherit (nixosTests) radarr;
    };

    updateScript = writers.writePython3 "radarr-updater" {
      flakeIgnore = [ "E501" ];
      libraries = with python3Packages; [ requests ];

      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath [
          nix
          prefetch-yarn-deps
        ])
      ];
    } ./update.py;
  };

  meta = {
    description = "Usenet/BitTorrent movie downloader";
    homepage = "https://radarr.video";
    changelog = "https://github.com/Radarr/Radarr/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      purcell
      nyanloutre
      karaolidis
    ];

    mainProgram = "Radarr";
    # platforms inherited from dotnet-sdk.
  };
}
