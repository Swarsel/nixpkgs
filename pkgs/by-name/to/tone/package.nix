{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  ffmpeg-full,
  nix-update-script,
  versionCheckHook,
}:

buildDotnetModule rec {
  pname = "tone";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "sandreas";
    repo = "tone";
    tag = "v${version}";
    hash = "sha256-yqcxqwlCfVDTv5jkcneimlS5EgnDlB7ZvxPt53t9jbQ=";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dotnet-runtime = dotnetCorePackages.sdk_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetInstallFlags = [
    "-p:PublishSingleFile=false"
  ];

  executables = [ "tone" ];
  nugetDeps = ./deps.json;

  patchPhase = ''
    substituteInPlace tone/Program.cs \
      --replace-fail "@package_version@" ${version}
  '';

  projectFile = "tone/tone.csproj";
  runtimeDeps = [ ffmpeg-full ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross platform utility to dump and modify audio metadata for a wide variety of formats";
    homepage = "https://github.com/sandreas/tone";
    changelog = "https://github.com/sandreas/tone/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jvanbruegge
      jwillikers
    ];

    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "tone";
  };
}
