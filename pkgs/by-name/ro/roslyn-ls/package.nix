{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  expect,
  jq,
  runCommand,
  stdenvNoCC,
  testers,
}:
let
  pname = "roslyn-ls";
  # see https://github.com/dotnet/roslyn/blob/main/eng/targets/TargetFrameworks.props
  dotnet-sdk =
    with dotnetCorePackages;
    # required sdk
    sdk_10_0
    // {
      # with additional packages to minimize deps.json
      inherit
        (combinePackages [
          sdk_9_0
          sdk_8_0
        ])
        packages
        targetPackages
        ;
    };
  # should match the default NetVSCode property
  # see https://github.com/dotnet/roslyn/blob/main/eng/targets/TargetFrameworks.props
  dotnet-runtime = dotnetCorePackages.sdk_10_0.runtime;

  rid = dotnetCorePackages.systemToDotnetRid stdenvNoCC.targetPlatform.system;

  project = "Microsoft.CodeAnalysis.LanguageServer";
in
buildDotnetModule (finalAttrs: {
  inherit pname dotnet-sdk dotnet-runtime;
  # versioned independently from vscode-csharp
  # "roslyn" in here:
  # https://github.com/dotnet/vscode-csharp/blob/main/package.json
  version = "5.9.0-1.26314.1";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "roslyn";
    rev = "VSCode-CSharp-${finalAttrs.vsVersion}";
    hash = "sha256-Cq1ynxtNaguLhVSSR04wUkqrn4/0YmwGxHfBZC4zMS8=";
  };

  patches = [
    # until made configurable/and or different location
    # https://github.com/dotnet/roslyn/issues/76892
    ./cachedirectory.patch
  ];

  postPatch = ''
    # Upstream uses rollForward = latestPatch, which pins to an *exact* .NET SDK version.
    jq '.sdk.rollForward = "latestMinor"' < global.json > global.json.tmp
    mv global.json.tmp global.json
  '';

  nativeBuildInputs = [ jq ];

  # problem and solution:
  # BuildHost project within roslyn is running Build target during publish -> --no-build removed
  installPhase = ''
    runHook preInstall

    env dotnet publish $dotnetProjectFiles \
        -p:ContinuousIntegrationBuild=true \
        -p:Deterministic=true \
        -p:InformationalVersion=$version \
        -p:PublishTrimmed=false \
        -p:OverwriteReadOnlyFiles=true \
        --configuration Release \
        --no-self-contained \
        --output "$out/lib/$pname" \
        --no-restore \
        --runtime ${rid} \
        ''${dotnetInstallFlags[@]}  \
        ''${dotnetFlags[@]}

    runHook postInstall
  '';

  postInstall = ''
    # fake executable that we substitute in postFixup
    touch $out/lib/$pname/${project}
    chmod +x $out/lib/$pname/${project}
  '';

  # force dotnet-runtime to run the dll
  # but keep the wrapper created with useDotnetFromEnv to allow LS to work properly on codebases
  postFixup = ''
    rm -f $out/lib/$pname/${project}
    substituteInPlace $out/bin/${project} \
      --replace-fail "$out/lib/$pname/${project}" "${lib.getExe dotnet-runtime}\" \"$out/lib/$pname/${project}.dll"
  '';

  dotnetFlags = [
    "-p:TargetRid=${rid}"
    # we don't want to build the binary
    # and useAppHost is not enough, need to explicilty set to false
    "-p:UseAppHost=false"
    # avoid platform-specific crossgen packages
    "-p:PublishReadyToRun=false"
    # this removes the Microsoft.WindowsDesktop.App.Ref dependency
    "-p:EnableWindowsTargeting=false"
    # avoid unnecessary packages in deps.json
    "-p:EnableAppHostPackDownload=false"
    "-p:EnableRuntimePackDownload=false"
  ];

  executables = [ project ];
  nugetDeps = ./deps.json;
  projectFile = "src/LanguageServer/${project}/${project}.csproj";
  # don't build binary
  useAppHost = false;
  useDotnetFromEnv = true;
  vsVersion = "2.144.9-prerelease";

  passthru = {
    tests =
      let
        with-sdk =
          sdk:
          runCommand "with-${if sdk ? version then sdk.version else "no"}-sdk"
            {
              nativeBuildInputs = [
                finalAttrs.finalPackage
                sdk
                expect
              ];

              meta.timeout = 60;
            }
            ''
              HOME=$TMPDIR
              expect <<"EOF"
                spawn ${finalAttrs.meta.mainProgram} --stdio --logLevel Information --extensionLogDirectory log
                expect_before timeout {
                  send_error "timeout!\n"
                  exit 1
                }
                expect "Language server initialized"
                send \x04
                expect eof
                catch wait result
                exit [lindex $result 3]
              EOF
              touch $out
            '';
      in
      {
        version = testers.testVersion { package = finalAttrs.finalPackage; };
        no-sdk = with-sdk null;
        with-net10-sdk = with-sdk dotnetCorePackages.sdk_10_0;
        # Make sure we can run with any supported SDK version, as well as without
        with-net8-sdk = with-sdk dotnetCorePackages.sdk_8_0;
        with-net9-sdk = with-sdk dotnetCorePackages.sdk_9_0;
      };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Language server behind C# Dev Kit for Visual Studio Code";
    homepage = "https://github.com/dotnet/vscode-csharp";
    changelog = "https://github.com/dotnet/vscode-csharp/releases/tag/v${finalAttrs.vsVersion}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ konradmalik ];
    mainProgram = "Microsoft.CodeAnalysis.LanguageServer";
  };
})
