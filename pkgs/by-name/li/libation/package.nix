{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  glew,
  glib,
  gtk3,
  libxcursor,
  libxi,
  libxrandr,
  nix-update-script,
  wrapGAppsHook3,
}:

buildDotnetModule rec {
  pname = "libation";
  version = "13.5.0";

  src = fetchFromGitHub {
    owner = "rmcrackan";
    repo = "Libation";
    tag = "v${version}";
    hash = "sha256-KF7iFvVRmsWFMkFiVE4QosQmpqYeFx7yqIw7u0Cf80o=";
  };

  nativeBuildInputs = [ wrapGAppsHook3 ];

  postInstall = ''
    install -Dm644 LoadByOS/LinuxConfigApp/libation_glass.svg $out/share/icons/hicolor/scalable/apps/libation.svg
    install -Dm644 LoadByOS/LinuxConfigApp/Libation.desktop $out/share/applications/libation.desktop
  '';

  preFixup = ''
    wrapDotnetProgram $out/lib/libation/Libation $out/bin/libation
    wrapDotnetProgram $out/lib/libation/LibationCli $out/bin/libationcli
    wrapDotnetProgram $out/lib/libation/Hangover $out/bin/hangover
  '';

  # wrap manually, because we need lower case executables
  dontDotnetFixup = true;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0_1xx;

  dotnetFlags = [
    "-p:PublishReadyToRun=false"
    # for some reason this is set to win-x64 in the project files
    "-p:RuntimeIdentifier="
  ];

  nugetDeps = ./deps.json;

  projectFile = [
    "LibationAvalonia/LibationAvalonia.csproj"
    "LibationCli/LibationCli.csproj"
    "HangoverAvalonia/HangoverAvalonia.csproj"
  ];

  runtimeDeps = [
    # For Avalonia UI
    glew
    libxrandr
    libxi
    libxcursor
    # For file dialogs
    gtk3
    # For web view (login dialog); loaded via P/Invoke at runtime
    glib
  ];

  sourceRoot = "${src.name}/Source";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Audible audiobook manager";
    homepage = "https://github.com/rmcrackan/Libation";
    changelog = "https://github.com/rmcrackan/Libation/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      tomasajt
      tebriel
    ];

    mainProgram = "libation";
  };
}
