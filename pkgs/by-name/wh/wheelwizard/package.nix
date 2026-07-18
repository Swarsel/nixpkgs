{
  lib,
  fetchFromGitHub,
  avalonia,
  buildDotnetModule,
  desktop-file-utils,
  dotnetCorePackages,
  # Runtime dependencies
  libglvnd,
  makeDesktopItem,
  makeWrapper,
  # passthru
  nix-update-script,
}:
buildDotnetModule (finalAttrs: {
  pname = "wheelwizard";
  version = "2.4.11";

  src = fetchFromGitHub {
    owner = "TeamWheelWizard";
    repo = "WheelWizard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8Dex2PDgwnxKguf0jtC1T0+jm7bA7jDfvspwkiqJgUg";
  };

  postPatch = ''
    rm .config/dotnet-tools.json
  '';

  nativeBuildInputs = [
    makeWrapper
    desktop-file-utils
  ];

  buildInputs = [
    avalonia
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/wheelwizard $out/bin
    cp -r WheelWizard/bin/Release/net8.0/*/* $out/lib/wheelwizard/

    makeWrapper $out/lib/wheelwizard/WheelWizard $out/bin/WheelWizard \
      --prefix PATH : ${lib.makeBinPath [ finalAttrs.dotnet-runtime ]}

    install -D $desktopItem/share/applications/* -t $out/share/applications

    runHook postInstall
  '';

  postFixup = ''
    rm $out/bin/*.{so,dylib}
  '';

  buildType = "Release";

  desktopItem = makeDesktopItem {
    categories = [ "Game" ];
    comment = "WheelWizard, Retro Rewind Launcher";
    desktopName = "Wheel Wizard";
    exec = "WheelWizard";
    name = "wheelwizard";
  };

  dotnet-runtime = dotnetCorePackages.runtime_8_0-bin;
  dotnet-sdk = dotnetCorePackages.sdk_8_0-bin;
  mapNuGetDependencies = true;
  nugetDeps = ./deps.json;
  projectFile = "WheelWizard";

  runtimeDeps = [
    libglvnd
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "WheelWizard, Retro Rewind Launcher";
    homepage = "https://github.com/TeamWheelWizard/WheelWizard";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ DerHalbGrieche ];
    platforms = lib.platforms.linux;
    mainProgram = "WheelWizard";
  };
})
