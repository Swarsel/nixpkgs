{
  lib,
  stdenv,
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
  sqlite,
  stdenvNoCC,
  # update script
  writers,
  yarn,
}:
let
  version = "2.4.0.5397";
  # The dotnet8 compatibility patches also change `yarn.lock`, so we must pass
  # the already patched lockfile to `fetchYarnDeps`.
  src = applyPatches {
    postPatch = ''
      mv src/NuGet.config NuGet.Config
    '';

    src = fetchFromGitHub {
      owner = "Prowlarr";
      repo = "Prowlarr";
      tag = "v${version}";
      hash = "sha256-cLFzCPSG0cB2K3KPNrN0zNnmZMEX3olJajNFGxmYoAM=";
    };
  };
  rid = dotnetCorePackages.systemToDotnetRid stdenvNoCC.hostPlatform.system;
in
buildDotnetModule {
  inherit version src;
  pname = "prowlarr";
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

  doCheck = !stdenv.hostPlatform.isDarwin;

  postInstall = ''
    cp -a -- _output/UI "$out/lib/prowlarr/UI"
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
  ];

  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetFlags = [
    "--property:TargetFramework=net8.0"
    "--property:EnableAnalyzers=false"
    "--property:SentryUploadSymbols=false" # Fix Sentry upload failed warnings
    # Override defaults in src/Directory.Build.props that use current time.
    "--property:Copyright=Copyright 2014-2025 prowlarr.com (GNU General Public v3)"
    "--property:AssemblyVersion=${version}"
    "--property:AssemblyConfiguration=master"
    "--property:RuntimeIdentifier=${rid}"
  ];

  executables = [ "Prowlarr" ];
  nugetDeps = ./deps.json;

  projectFile = [
    "src/NzbDrone.Console/Prowlarr.Console.csproj"
    "src/NzbDrone.Mono/Prowlarr.Mono.csproj"
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
    "src/Prowlarr.Api.V1.Test/Prowlarr.Api.V1.Test.csproj"
    "src/NzbDrone.Common.Test/Prowlarr.Common.Test.csproj"
    "src/NzbDrone.Core.Test/Prowlarr.Core.Test.csproj"
    "src/NzbDrone.Host.Test/Prowlarr.Host.Test.csproj"
    "src/NzbDrone.Libraries.Test/Prowlarr.Libraries.Test.csproj"
    "src/NzbDrone.Mono.Test/Prowlarr.Mono.Test.csproj"
    "src/NzbDrone.Test.Common/Prowlarr.Test.Common.csproj"
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-PZw+Q7CcHkbb2bhZKSPE0kvPIhWxWQIqr7/UZlPdqtY=";
    yarnLock = "${src}/yarn.lock";
  };

  passthru = {
    tests = {
      inherit (nixosTests) prowlarr;
    };

    updateScript = writers.writePython3 "prowlarr-updater" {
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
    description = "Indexer manager/proxy built on the popular arr .net/reactjs base stack";
    homepage = "https://prowlarr.com/";
    changelog = "https://github.com/Prowlarr/Prowlarr/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      pizzapim
      nyanloutre
    ];

    mainProgram = "Prowlarr";
    # platforms inherited from dotnet-sdk.
  };
}
