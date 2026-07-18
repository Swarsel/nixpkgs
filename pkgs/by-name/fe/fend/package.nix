{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  fend,
  installShellFiles,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pandoc,
  pkg-config,
  runCommand,
  rustPlatform,
  testers,
  writeText,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fend";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "printfn";
    repo = "fend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XIdz7s8DCmXSeFIC06C+/wLDyMBcqIrjDSQUAhxX72s=";
  };

  nativeBuildInputs = [
    pandoc
    installShellFiles
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    pkg-config
    openssl
  ];

  cargoHash = "sha256-mDsAZvnBGXhEl2Qbww2svPznl6k9b44zGdMkeejIWVU=";

  postBuild = ''
    patchShebangs --build ./documentation/build.sh
    ./documentation/build.sh
  '';

  postInstall = ''
    install -D -m 444 $src/icon/icon.svg $out/share/icons/hicolor/scalable/apps/fend.svg
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    [[ "$($out/bin/fend "1 km to m")" = "1000 m" ]]
  '';

  preFixup = ''
    installManPage documentation/fend.1
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Calculator"
        "ConsoleOnly"
      ];

      comment = "Arbitrary-precision unit-aware calculator";
      desktopName = "fend";
      exec = "fend";
      genericName = "Calculator";
      icon = "fend";
      name = "fend";
      terminal = true;
    })
  ];

  passthru = {
    tests = {
      version = testers.testVersion { package = fend; };

      units = testers.testEqualContents {
        actual = runCommand "actual" { } ''
          ${lib.getExe fend} '(100 meters) / (10 seconds) to kph' > $out
        '';

        assertion = "fend does simple math and unit conversions";

        expected = writeText "expected" ''
          36 kph
        '';
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Arbitrary-precision unit-aware calculator";
    homepage = "https://github.com/printfn/fend";
    changelog = "https://github.com/printfn/fend/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      djanatyn
      liff
    ];

    mainProgram = "fend";
  };
})
