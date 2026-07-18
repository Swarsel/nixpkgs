{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoPatchelfHook,
  cmake,
  fetchzip,
  git,
  jq,
  ninja,
  nix-prefetch-git,
  nixosTests,
  perl,
  python3,
  removeReferencesTo,
  stdenvNoCC,
  writers,
}:

let

  info = builtins.fromJSON (builtins.readFile ./info.json);

  opensslSrc = fetchurl info.openssl;

  toolchain = import ./toolchain-bin.nix {
    inherit
      stdenv
      lib
      fetchzip
      autoPatchelfHook
      ;
  };

in

stdenvNoCC.mkDerivation rec {

  pname = "osquery";
  version = info.osquery.rev;
  src = fetchFromGitHub info.osquery;

  patches = [
    ./Remove-git-reset.patch
  ];

  postPatch = ''
    substituteInPlace cmake/install_directives.cmake --replace "/control" "control"
  '';

  nativeBuildInputs = [
    cmake
    git
    perl
    python3
    ninja
    autoPatchelfHook
    jq
    removeReferencesTo
  ];

  postInstall = ''
    rm -rf $out/control
    remove-references-to -t ${toolchain} $out/bin/osqueryd
  '';

  configurePhase = ''
    mkdir build
    cd build
    cmake .. \
      -DCMAKE_INSTALL_PREFIX=$out \
      -DOSQUERY_TOOLCHAIN_SYSROOT=${toolchain} \
      -DOSQUERY_VERSION=${version} \
      -DCMAKE_PREFIX_PATH=${toolchain}/usr/lib/cmake \
      -DCMAKE_LIBRARY_PATH=${toolchain}/usr/lib \
      -DOSQUERY_OPENSSL_ARCHIVE_PATH=${opensslSrc} \
      -GNinja
  '';

  disallowedReferences = [ toolchain ];

  passthru = {
    inherit opensslSrc toolchain;

    tests = {
      inherit (nixosTests) osquery;
    };

    updateScript = writers.writePython3 "osquery-update" {
      makeWrapperArgs = "--prefix PATH : ${lib.makeBinPath [ nix-prefetch-git ]}";
    } (builtins.readFile ./update.py);
  };

  meta = {
    description = "SQL powered operating system instrumentation, monitoring, and analytics";
    homepage = "https://osquery.io";

    license = with lib.licenses; [
      gpl2Only
      asl20
    ];

    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      znewman01
      lewo
      lesuisse
    ];

    platforms = lib.platforms.linux;
  };
}
