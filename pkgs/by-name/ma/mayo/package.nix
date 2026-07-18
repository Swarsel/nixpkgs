{
  lib,
  stdenv,
  fetchFromGitHub,
  assimp,
  cmake,
  copyDesktopItems,
  ctestCheckHook,
  makeDesktopItem,
  opencascade-occt,
  qt6,
  # options
  withAssimp ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mayo";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "fougue";
    repo = "mayo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A2ODbbOyoWIhKOWGzSQS2gUF8kpWlN8hN8CdeumAUps=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    copyDesktopItems
    cmake
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    opencascade-occt
  ]
  ++ lib.optional withAssimp assimp;

  cmakeFlags = [
    (lib.cmakeOptionType "string" "Mayo_VersionMajor" (lib.versions.major finalAttrs.version))
    (lib.cmakeOptionType "string" "Mayo_VersionMinor" (lib.versions.minor finalAttrs.version))
    (lib.cmakeOptionType "string" "Mayo_VersionPatch" (lib.versions.patch finalAttrs.version))
    (lib.cmakeBool "Mayo_BuildTests" finalAttrs.doCheck)
  ]
  ++ lib.optional withAssimp "-DMayo_BuildPluginAssimp=ON";

  doCheck = true;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 mayo $out/bin/mayo
    install -Dm755 mayo-conv $out/bin/mayo-conv

    pushd ..
    install -Dm444 images/appicon.svg "$out/share/icons/hicolor/scalable/apps/mayo.svg"
    install -Dm444 images/appicon_256.png "$out/share/icons/hicolor/256x256/apps/mayo.png"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    install -Dm444 images/appicons.icns "$out/Applications/Mayo.app/Contents/Resources/mayo.icns"
  ''
  + ''
    popd

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Graphics"
        "3DGraphics"
        "Engineering"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Mayo";
      exec = "mayo";
      icon = "mayo";
      name = "mayo";
    })
  ];

  meta = {
    description = "3D CAD viewer and converter based on Qt + OpenCascade";
    homepage = "https://github.com/fougue/mayo";
    changelog = "https://github.com/fougue/mayo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.gigahawk ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "mayo";
  };
})
