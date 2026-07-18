{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  git,
  libGL,
  libicns,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  xdg-utils,
}:

buildDotnetModule (finalAttrs: {
  pname = "sourcegit";
  version = "2026.11";

  src = fetchFromGitHub {
    owner = "sourcegit-scm";
    repo = "sourcegit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tt0YgRnX7v2wqeK7/JiQiuRXIAB+pPy1yetfPlg5i9c=";
    fetchSubmodules = true;
  };

  patches = [ ./fix-darwin-git-path.patch ];

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
    libicns
  ];

  # add fallback binaries to use if the user doesn't already have them in their PATH
  preInstall = ''
    makeWrapperArgs+=(
      --suffix PATH : ${lib.makeBinPath finalAttrs.runtimePathDeps}
    )
  '';

  postInstall =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      # extract the .icns file into multiple .png files
      # where the format of the .png file names is App_"$n"x"$n"x32.png

      icns2png -x build/resources/app/App.icns

      for f in App_*x32.png; do
        res=''${f//App_}
        res=''${res//x32.png}
        install -Dm644 $f "$out/share/icons/hicolor/$res/apps/SourceGit.png"
      done
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      install -Dm644 build/resources/app/App.icns $out/Applications/SourceGit.app/Contents/Resources/App.icns

      substitute build/resources/app/App.plist $out/Applications/SourceGit.app/Contents/Info.plist \
        --replace-fail "SOURCE_GIT_VERSION" "${finalAttrs.version}"

      mkdir -p $out/Applications/SourceGit.app/Contents/MacOS
      ln -s $out/bin/SourceGit $out/Applications/SourceGit.app/Contents/MacOS/SourceGit
    '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Development" ];
      comment = finalAttrs.meta.description;
      desktopName = "SourceGit";
      exec = "SourceGit";
      icon = "SourceGit";
      name = "SourceGit";
      terminal = false;
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetFlags = [
    "-p:DisableUpdateDetection=true"
    "-p:DisableAOT=true"
  ];

  executables = [ "SourceGit" ];
  nugetDeps = ./deps.json;
  projectFile = [ "src/SourceGit.csproj" ];

  # these are dlopen-ed at runtime
  # libxi is needed for right-click support
  # libGL is needed for GPU-accelerated rendering (without it, Avalonia falls back to software rendering)
  # not sure about what the other ones are needed for, but I'll include them anyways
  runtimeDeps = [
    libGL
    libxcursor
    libxext
    libxi
    libxrandr
  ];

  # Note: users can use `.overrideAttrs` to append to this list
  runtimePathDeps = [
    git
    xdg-utils
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Free & OpenSource GUI client for GIT users";
    homepage = "https://github.com/sourcegit-scm/sourcegit";
    changelog = "https://github.com/sourcegit-scm/sourcegit/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "SourceGit";
  };
})
