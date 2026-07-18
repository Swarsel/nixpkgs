{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  makeDesktopItem,
  nix-update-script,
  writeText,
}:
buildDotnetModule (finalAttrs: {
  pname = "msbuild-structured-log-viewer";
  version = "2.3.150";

  src = fetchFromGitHub {
    owner = "KirillOsenkov";
    repo = "MSBuildStructuredLog";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HTWPsVl/pMi+lMSax5JNtbPXHeqD8QxfvLp2bhVxfPs=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
  ];

  postFixup = ''
    wrapDotnetProgram $out/lib/msbuild-structured-log-viewer/StructuredLogViewer.Avalonia $out/bin/${finalAttrs.meta.mainProgram}
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm444 $src/src/StructuredLogViewer/icons/msbuild-structured-log-viewer.png $out/share/icons/hicolor/32x32/apps/msbuild-structured-log-viewer.png
    install -Dm444 ${./mimetype.xml} $out/share/mime/packages/binlog.xml
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace src/StructuredLogViewer.Avalonia/Info.plist \
      --replace-fail "0.0.1" "${finalAttrs.version}"

    install -Dm444 src/StructuredLogViewer.Avalonia/Info.plist $out/Applications/StructuredLogViewer.app/Contents/Info.plist
    install -Dm444 src/StructuredLogViewer.Avalonia/StructuredLogViewer.icns $out/Applications/StructuredLogViewer.app/Contents/Resources/StructuredLogViewer.icns
    mkdir -p $out/Applications/StructuredLogViewer.app/Contents/MacOS
    ln -s $out/bin/${finalAttrs.meta.mainProgram} $out/Applications/StructuredLogViewer.app/Contents/MacOS/StructuredLogViewer.Avalonia
  '';

  desktopItems = makeDesktopItem {
    categories = [ "Development" ];
    comment = finalAttrs.meta.description;
    desktopName = "MSBuild Structured Log Viewer";
    exec = finalAttrs.meta.mainProgram;
    icon = "msbuild-structured-log-viewer";

    mimeTypes = [
      "application/x-binlog"
    ];

    name = "msbuild-structured-log-viewer";
  };

  dontDotnetFixup = true;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetBuildFlags = [
    "-p:CustomAfterDirectoryBuildTargets=${writeText "StubGitVersioning.targets" ''
      <Project>
          <Target Name="GetBuildVersion" Returns="$(BuildVersion)" DependsOnTargets="GetAssemblyVersion">
              <PropertyGroup>
                  <BuildVersion>$(Version)</BuildVersion>
                  <AssemblyFileVersion>$(FileVersion)</AssemblyFileVersion>
                  <AssemblyInformationalVersion>$(InformationalVersion)</AssemblyInformationalVersion>
              </PropertyGroup>
          </Target>
      </Project>
    ''}"
  ];

  nugetDeps = ./deps.json;
  projectFile = [ "src/StructuredLogViewer.Avalonia/StructuredLogViewer.Avalonia.csproj" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rich interactive log viewer for MSBuild logs";
    homepage = "https://github.com/KirillOsenkov/MSBuildStructuredLog";
    changelog = "https://github.com/KirillOsenkov/MSBuildStructuredLog/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [ js6pak ];
    mainProgram = "msbuild-structured-log-viewer";
  };
})
