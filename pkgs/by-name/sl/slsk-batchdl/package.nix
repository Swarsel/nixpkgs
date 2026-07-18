{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:
buildDotnetModule (finalAttrs: {
  pname = "slsk-batchdl";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "fiso64";
    repo = "slsk-batchdl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H10pApWZ6zUkL1FuSrpbEzGGpDVAiBJB2aZtV9jDTz4=";
  };

  postPatch = ''
    # .NET 6 is EOL, .NET 8 works fine modulo the trimming flag.
    # See: https://github.com/fiso64/slsk-batchdl/issues/112
    substituteInPlace \
        slsk-batchdl/slsk-batchdl.csproj \
        slsk-batchdl.Tests/slsk-batchdl.Tests.csproj \
        --replace-fail "<TargetFramework>net6.0</TargetFramework>" "<TargetFramework>net10.0</TargetFramework>"
  '';

  # Tests fail to build.
  # See: https://github.com/fiso64/slsk-batchdl/issues/111
  # testProjectFile = "slsk-batchdl.Tests/slsk-batchdl.Tests.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetFlags = [
    "--property:PublishSingleFile=true"
    # Note: This breaks Spotify authentication!
    # See: https://github.com/fiso64/slsk-batchdl/issues/112
    # "--property:PublishTrimmed=true"
  ];

  executables = [ "sldl" ];
  nugetDeps = ./deps.json;
  projectFile = "slsk-batchdl/slsk-batchdl.csproj";
  selfContainedBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Advanced download tool for Soulseek";
    homepage = "https://github.com/fiso64/slsk-batchdl";
    license = lib.licenses.gpl3Only;

    maintainers = [
      lib.maintainers._9999years
    ];

    mainProgram = "sldl";
  };
})
