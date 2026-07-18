{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchzip,
  nix-update-script,
  qdiskinfo,
  qt6,
  smartmontools,
  themeBundle ? null,
}:

let
  isThemed = themeBundle != null && themeBundle != { };
  themeBundle' =
    if isThemed then
      {
        rightCharacter = false;
      }
      // themeBundle
    else
      { rightCharacter = false; };
in

# check theme bundle
assert
  isThemed
  -> (
    themeBundle' ? src
    && themeBundle' ? paths.bgDark
    && themeBundle' ? paths.bgLight
    && themeBundle' ? paths.status
    && themeBundle' ? rightCharacter
  );

stdenv.mkDerivation (finalAttrs: {
  pname = "qdiskinfo";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "edisionnano";
    repo = "QDiskInfo";
    tag = finalAttrs.version;
    hash = "sha256-FufbF0oEqpYgXnfzUZJ3tTN2jJoIQX4UB3yURRV7y00=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    smartmontools
  ];

  cmakeFlags = [
    "-DQT_VERSION_MAJOR=6"
  ]
  ++ lib.optionals isThemed [ "-DINCLUDE_OPTIONAL_RESOURCES=ON" ]
  ++ (
    if themeBundle'.rightCharacter then
      [ "-DCHARACTER_IS_RIGHT=ON" ]
    else
      [ "-DCHARACTER_IS_RIGHT=OFF" ]
  );

  postInstall = ''
    wrapProgram $out/bin/QDiskInfo \
      --suffix PATH : ${smartmontools}/bin
  '';

  cmakeBuildType = "MinSizeRel";

  patchPhase = lib.optionalString isThemed ''
    export SRCPATH=${themeBundle'.src}/CdiResource/themes/
    export DESTPATH=$sourceRoot/dist/theme/
    mkdir -p $DESTPATH
    if [ -n "${themeBundle'.paths.bgDark}" ]; then
      cp $SRCPATH/${themeBundle'.paths.bgDark} $DESTPATH/bg_dark.png
    fi
    if  [ -n "${themeBundle'.paths.bgLight}" ]; then
      cp $SRCPATH/${themeBundle'.paths.bgLight} $DESTPATH/bg_light.png
    fi
    cp $SRCPATH/${themeBundle'.paths.status}/SDdiskStatusBad-300.png $DESTPATH/bad.png
    cp $SRCPATH/${themeBundle'.paths.status}/SDdiskStatusCaution-300.png $DESTPATH/caution.png
    cp $SRCPATH/${themeBundle'.paths.status}/SDdiskStatusGood-300.png $DESTPATH/good.png
    cp $SRCPATH/${themeBundle'.paths.status}/SDdiskStatusUnknown-300.png $DESTPATH/unknown.png
  '';

  postUnpack = ''
    cp -r $sourceRoot $TMPDIR/src
    sourceRoot=$TMPDIR/src
  '';

  passthru =
    let
      themeSources = import ./sources.nix { inherit fetchzip; };
    in
    rec {
      tests = lib.flip lib.mapAttrs themeBundles (
        themeName: themeBundle:
        (qdiskinfo.override { inherit themeBundle; }).overrideAttrs { pname = "qdiskinfo-${themeName}"; }
      );

      themeBundles = import ./themes.nix { inherit themeSources; };
      updateScript = nix-update-script { };
    };

  meta = {
    description = "CrystalDiskInfo alternative for Linux";
    homepage = "https://github.com/edisionnano/QDiskInfo";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      roydubnium
      ryand56
    ];

    platforms = lib.platforms.linux;
    mainProgram = "QDiskInfo";
  };
})
