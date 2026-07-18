{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildNpmPackage,
  makeDesktopItem,
  makeWrapper,
  nwjs,
  python3,
  unstableGitUpdater,
}:

let
  # Use unstable because it has improvements for finding python
  version = "0.12-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "FPGAwars";
    repo = "icestudio";
    rev = "8607f7ef538c4b447362b2ab90aece2fbb7d1b75";
    hash = "sha256-8KYwlOKKmTQza71cVpssOGJJNwIUvMHMYcokhK/LhEo=";
  };

  collection = fetchurl {
    hash = "sha256-F2cAqkTPC7xfGnPQiS8lTrD4y34EkHFUEDPVaYzVVg8=";
    url = "https://github.com/FPGAwars/collection-default/archive/v0.4.1.zip";
  };

  app = buildNpmPackage {
    inherit version src;
    pname = "icestudio-app";
    npmDepsHash = "sha256-Dpnx23iq0fK191DXFgIfnbi+MLEp65H6eL81Icg4H4U=";

    installPhase = ''
      cp -r . $out
    '';

    dontNpmBuild = true;
    sourceRoot = "${src.name}/app";
  };

  desktopItem = makeDesktopItem {
    categories = [ "Development" ];
    comment = "Visual editor for open FPGA boards";
    desktopName = "Icestudio";
    exec = "icestudio";
    icon = "icestudio";
    name = "icestudio";
    terminal = false;
  };
in
buildNpmPackage rec {
  inherit version src;
  pname = "icestudio";
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];
  npmDepsHash = "sha256-QHd4d0BQXqAs/4WnnawCW/tJvSbWOz++RwomNG4XBuU=";

  buildPhase = ''
    runHook preBuild

    # Copy the `app` derivation into the folder expected for grunt
    cp -r ${app}/* app

    # Copy the cached `collection` derivation into the cache location so that
    # grunt avoids downloading it
    install -m444 -D ${collection} cache/collection/collection-default.zip

    ./node_modules/.bin/grunt getcollection

    # Use grunt to distribute package
    # TODO: support aarch64
    ./node_modules/.bin/grunt dist \
        --platform=none    `# skip platform-specific steps` \
        --dont-build-nwjs  `# use the nwjs package shipped by Nix` \
        --dont-clean-tmp   `# skip cleaning the tmp folder as we'll use it in $out`

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist/tmp $out

    for size in 16 32 64 128 256; do
      install -Dm644 docs/resources/icons/"$size"x"$size"/apps/icon.png \
        $out/share/icons/hicolor/"$size"x"$size"/apps/icestudio.png
    done

    install -Dm644 ${desktopItem}/share/applications/icestudio.desktop -t $out/share/applications

    makeWrapper ${nwjs}/bin/nw $out/bin/${pname} \
        --add-flags $out \
        --prefix PATH : "${python3}/bin"

    runHook postInstall
  '';

  npmFlags = [
    # Use the legacy dependency resolution, with less strict version
    # requirements for transative dependencies
    "--legacy-peer-deps"

    # We want to avoid call the scripts/postInstall.sh until we copy the
    # collection and app derivation we do that on installPhase
    "--ignore-scripts"
  ];

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
  };

  meta = {
    description = "Visual editor for open FPGA boards";
    homepage = "https://github.com/FPGAwars/icestudio/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      kiike
      jleightcap
      rcoeurjoly
      amerino
    ];

    platforms = lib.platforms.linux;
    mainProgram = "icestudio";
    teams = [ lib.teams.ngi ];
  };
}
