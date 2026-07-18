{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  desktopToDarwinBundle,
  dotnetCorePackages,
  ffmpeg-headless,
  libGL,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  openssl,
  vulkan-loader,
  writeText,
}:
let
  inherit (dotnetCorePackages) fetchNupkg;

  buildInfo = {
    id = "NixOS";
    name = "for NixOS";
  };

  appSettings = writeText "appsettings.json" (
    lib.strings.toJSON {
      AnalyticsUrl = "https://api.pixieditor.net/analytics/";
      PixiEditorApiKey = "waIvElX0fPqaxnyD7Rh1SSEvdq8qfKUs";
      PixiEditorApiUrl = "https://auth.pixieditor.net";
    }
  );

in
buildDotnetModule (finalAttrs: {
  pname = "pixieditor";
  version = "2.1.1.5";

  src = fetchFromGitHub {
    owner = "PixiEditor";
    repo = "PixiEditor";
    tag = finalAttrs.version;
    hash = "sha256-XtDcAnMgNc4Su2hj5OV2SP+LFIAMSfH8h2LLw+VbHok=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace ./src/PixiEditor/Helpers/VersionHelpers.cs \
      --replace-fail 'builder.Append(" Release Build");' 'builder.Append(" ${buildInfo.name}");' \
      --replace-fail 'return "Release";' 'return "${buildInfo.id}";';

    substituteInPlace ./src/PixiEditor/Models/ExceptionHandling/CrashReport.cs \
      --replace-fail 'ShellExecute(fileName,' 'ShellExecute("${placeholder "out"}/bin/pixieditor",';

    rm -rf ./src/PixiEditor.AnimationRenderer.FFmpeg/ThirdParty/{Linux,Macos,Windows}/*
    substituteInPlace ./src/PixiEditor.AnimationRenderer.FFmpeg/FFMpegRenderer.cs \
      --replace-fail 'new FFOptions() { BinaryFolder = binaryPath }' 'new FFOptions() { BinaryFolder = "${ffmpeg-headless}/bin" }' \
      --replace-fail 'MakeExecutableIfNeeded(binaryPath);' ' ';

    cp src/nuget.config .
  '';

  nativeBuildInputs = [
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  postInstall = ''
    install -Dm644 ${appSettings} $out/lib/pixieditor/appsettings.json;

    install -Dm644 ${./mimeinfo.xml} $out/share/mime/packages/pixieditor.xml;

    install -Dm644 src/PixiEditor/Images/PixiEditorLogo.svg \
      $out/share/icons/hicolor/scalable/apps/pixieditor.svg;
  '';

  postFixup = ''
    mv $out/bin/PixiEditor.Desktop $out/bin/pixieditor
  '';

  buildType = "ReleaseNoUpdate";

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Graphics"
        "2DGraphics"
        "RasterGraphics"
        "VectorGraphics"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "PixiEditor";
      exec = "pixieditor %f";
      extraConfig.SingleMainWindow = "true";
      genericName = "2D Editor";
      icon = "pixieditor";

      keywords = [
        "editor"
        "image"
        "2d"
        "graphics"
        "design"
        "vector"
        "raster"
      ];

      mimeTypes = [
        "application/x-pixieditor"
      ];

      name = "pixieditor";
      startupWMClass = "pixieditor";
      terminal = false;
      tryExec = "pixieditor";
      type = "Application";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  dotnetFlags = [
    "-p:RuntimeIdentifier=${dotnetCorePackages.systemToDotnetRid stdenv.hostPlatform.system}"
  ];

  executables = [ "PixiEditor.Desktop" ];
  linkNugetPackages = true;
  nugetDeps = ./deps.json;

  projectFile = [
    "src/PixiEditor.Desktop/PixiEditor.Desktop.csproj"
    "src/PixiEditor/PixiEditor.csproj"
    (
      if stdenv.hostPlatform.isLinux then
        "src/PixiEditor.Linux/PixiEditor.Linux.csproj"
      else
        "src/PixiEditor.MacOs/PixiEditor.MacOs.csproj"
    )
    "src/PixiEditor.Platform.Standalone/PixiEditor.Platform.Standalone.csproj"
  ];

  runtimeDeps = [
    vulkan-loader
    openssl
    libGL
    libx11
    libice
    libsm
    libxi
    libxcursor
    libxext
    libxrandr
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Universal editor for all your 2D needs";

    longDescription = ''
      PixiEditor is a universal 2D platform that aims to provide you with tools and features for all your 2D needs.
      Create beautiful sprites for your games, animations, edit images, create logos. All packed in an eye-friendly dark theme
    '';

    homepage = "https://pixieditor.net/";
    changelog = "https://github.com/PixiEditor/PixiEditor/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      griffi-gh
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "pixieditor";
  };
})
