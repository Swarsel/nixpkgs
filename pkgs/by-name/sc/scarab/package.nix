{
  lib,
  fetchFromGitHub,
  bc,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  fetchpatch2,
  icoutils,
  makeDesktopItem,
  versionCheckHook,
}:

buildDotnetModule rec {
  pname = "scarab";
  version = "2.7.0.0";

  src = fetchFromGitHub {
    owner = "fifty-six";
    repo = "scarab";
    tag = "v${version}";
    hash = "sha256-3sztodNIB05MHA2mMPAjizRHCjiOMYFNChsmXfQJq0I=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-N5a0QeJFQzvxX8RavwPILuLg10pWLVQhvodWpeUtItE=";
      name = "fix-test-missing-shasum.patch";
      url = "https://github.com/fifty-six/Scarab/commit/581e86fefb457772d2d067f094b6dafcc49a4075.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    icoutils
  ];

  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    # Icons for the desktop file
    icotool -x $src/Scarab/Assets/omegamaggotprime.ico

    sizes=(256 128 64 48 32 16)
    for i in ''${!sizes[@]}; do
      size=''${sizes[$i]}x''${sizes[$i]}
      install -D omegamaggotprime_''$((i+1))_''${size}x32.png $out/share/icons/hicolor/$size/apps/scarab.png
    done

    wrapProgram "$out/bin/Scarab" --run '. ${./scaling-settings.bash}'
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Hollow Knight mod installer and manager";
      desktopName = "Scarab";
      exec = "Scarab";
      icon = "scarab";
      name = "scarab";
      type = "Application";
    })
  ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "Scarab" ];
  nugetDeps = ./deps.json;
  projectFile = "Scarab/Scarab.csproj";

  runtimeDeps = [
    bc
  ];

  testProjectFile = "Scarab.Tests/Scarab.Tests.csproj";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Hollow Knight mod installer and manager";
    homepage = "https://github.com/fifty-six/Scarab";
    changelog = "https://github.com/fifty-six/Scarab/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      huantian
      sigmasquadron
    ];

    platforms = lib.platforms.linux;
    mainProgram = "Scarab";
    downloadPage = "https://github.com/fifty-six/Scarab/releases";
  };
}
