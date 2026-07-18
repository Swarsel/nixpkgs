{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  btrfs-progs,
  dosfstools,
  e2fsprogs,
  exfatprogs,
  f2fs-tools,
  jfsutils,
  makeWrapper,
  nix-update-script,
  ntfs3g,
  parted,
  util-linux,
  xfsprogs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tparted";
  version = "2025-11-02";

  src = fetchurl {
    url = "https://github.com/Kagamma/tparted/releases/download/${finalAttrs.version}/linux_x86-64_tparted_${finalAttrs.version}.tar.gz";
    hash = "sha256-dVVNr8VL8SP2gCdysbE28QgKWGOzfGoIdVIzJRxRp9M=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tparted $out/bin/
    mkdir -p $out/opt/tparted
    cp -r locale $out/opt/tparted/
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/tparted \
      --prefix PATH : ${
        lib.makeBinPath [
          parted
          util-linux
          dosfstools
          exfatprogs
          e2fsprogs
          ntfs3g
          btrfs-progs
          xfsprogs
          jfsutils
          f2fs-tools
        ]
      }
  '';

  runtimeDependencies = [
    parted
    util-linux
    dosfstools
    exfatprogs
    e2fsprogs
    ntfs3g
    btrfs-progs
    xfsprogs
    jfsutils
    f2fs-tools
  ];

  unpackPhase = ''
    runHook preUnpack
    tar xf $src
    runHook postUnpack
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Text-based user interface (TUI) frontend for parted";
    homepage = "https://github.com/Kagamma/tparted";
    changelog = "https://github.com/Kagamma/tparted/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "tparted";
  };
})
