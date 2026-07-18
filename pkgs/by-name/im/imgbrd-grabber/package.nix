{
  lib,
  stdenv,
  fetchFromGitHub,
  catch2,
  cmake,
  libpulseaudio,
  makeWrapper,
  nodejs,
  openssl,
  qt6,
  rsync,
  typescript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "imgbrd-grabber";
  version = "7.13.0";

  src = fetchFromGitHub {
    owner = "Bionus";
    repo = "imgbrd-grabber";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7EIXmqfTADG95vxKU1cFGnzZD3NJJN28HOF71YZD6nI=";
    fetchSubmodules = true;
  };

  patches = [
    ./fix-for-qt6.patch
    ./cmake4-compat.patch
  ];

  postPatch = ''
    # ensure the script uses the rsync package from nixpkgs
    substituteInPlace ../scripts/package.sh --replace-fail "rsync" "${lib.getExe rsync}"

    substituteInPlace gui/CMakeLists.txt \
      --replace-fail "find_package(Qt6 COMPONENTS " "find_package(Qt6 COMPONENTS NetworkAuth " \
      --replace-fail "set(QT_LIBRARIES " "set(QT_LIBRARIES Qt6::NetworkAuth "

    # the npm build step only runs typescript
    # run this step directly so it doesn't try and fail to download the unnecessary node_modules, etc.
    substituteInPlace ./sites/CMakeLists.txt --replace-fail "npm install" "npm run build"

    # link the catch2 sources from nixpkgs
    ln -sf ${catch2.src} tests/src/
  '';

  nativeBuildInputs = [
    makeWrapper
    qt6.wrapQtAppsHook
    cmake
  ];

  buildInputs =
    with qt6;
    [
      qtbase
      qtdeclarative
      qttools
      qtnetworkauth
      qtmultimedia
    ]
    ++ [
      openssl
      libpulseaudio
      typescript
      nodejs
    ];

  preBuild = ''
    export HOME=$TMPDIR

    # the package.sh script provides some install helpers
    # using this might make it easier to maintain/less likely for the
    # install phase to fail across version bumps
    patchShebangs ../scripts/package.sh
  '';

  postInstall = ''
    # move the binaries to the share/Grabber folder so
    # some relative links can be resolved (e.g. settings.ini)
    mv $out/bin/* $out/share/Grabber/

    cd ../..
    # run the package.sh with $out/share/Grabber as the $APP_DIR
    sh ./scripts/package.sh $out/share/Grabber

    # add symlinks for the binaries to $out/bin
    ln -s $out/share/Grabber/Grabber $out/bin/Grabber
    ln -s $out/share/Grabber/Grabber-cli $out/bin/Grabber-cli
  '';

  extraOutputsToLink = [ "doc" ];
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Very customizable imageboard/booru downloader with powerful filenaming features";
    homepage = "https://bionus.github.io/imgbrd-grabber/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      evanjs
      luftmensch-luftmensch
    ];

    mainProgram = "Grabber";
  };
})
