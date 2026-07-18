# This is an expression meant to be called from `./repart.nix`, it is NOT a
# NixOS module that can be imported.

{
  lib,
  baseName,
  black,
  btrfs-progs,
  compression,
  definitionsDirectory,
  # filesystem tools
  dosfstools,
  e2fsprogs,
  erofs-utils,
  fakeroot,
  fileSystems,
  finalPartitions,
  mtools,
  mypy,
  # arguments
  name,
  python3,
  ruff,
  runCommand,
  sectorSize,
  seed,
  split,
  squashfsTools,
  stdenvNoCC,
  systemd,
  util-linux,
  version,
  xfsprogs,
  xz,
  zeekstd,
  # compression tools
  zstd,
  createEmpty ? true,
  imageSize ? "auto",
  mkfsEnv ? { },
}:

let
  systemdArch =
    let
      inherit (stdenvNoCC) hostPlatform;
    in
    if hostPlatform.isAarch32 then
      "arm"
    else if hostPlatform.isAarch64 then
      "arm64"
    else if hostPlatform.isx86_32 then
      "x86"
    else if hostPlatform.isx86_64 then
      "x86-64"
    else if hostPlatform.isMips32 then
      "mips-le"
    else if hostPlatform.isMips64 then
      "mips64-le"
    else if hostPlatform.isPower then
      "ppc"
    else if hostPlatform.isPower64 then
      "ppc64"
    else if hostPlatform.isRiscV32 then
      "riscv32"
    else if hostPlatform.isRiscV64 then
      "riscv64"
    else if hostPlatform.isS390 then
      "s390"
    else if hostPlatform.isS390x then
      "s390x"
    else if hostPlatform.isLoongArch64 then
      "loongarch64"
    else if hostPlatform.isAlpha then
      "alpha"
    else
      hostPlatform.parsed.cpu.name;

  amendRepartDefinitions =
    runCommand "amend-repart-definitions.py"
      {
        # TODO: ruff does not splice properly in nativeBuildInputs
        depsBuildBuild = [ ruff ];

        nativeBuildInputs = [
          python3
          black
          mypy
        ];
      }
      ''
        install ${./amend-repart-definitions.py} $out
        patchShebangs --build $out

        black --check --diff $out
        ruff check --line-length 88 $out
        mypy --strict $out
      '';

  fileSystemToolMapping = {
    "btrfs" = [ btrfs-progs ];
    "erofs" = [ erofs-utils ];
    "ext4" = [ e2fsprogs.bin ];
    "squashfs" = [ squashfsTools ];
    "swap" = [ util-linux ];

    "vfat" = [
      dosfstools
      mtools
    ];

    "xfs" = [ xfsprogs ];
  };

  fileSystemTools = builtins.concatMap (f: fileSystemToolMapping."${f}") fileSystems;

  compressionPkg =
    {
      "xz" = xz;
      "zstd" = zstd;
      "zstd-seekable" = zeekstd;
    }
    ."${compression.algorithm}";

  compressionCommand =
    {
      "xz" = "xz --keep --verbose --threads=$NIX_BUILD_CORES -${toString compression.level}";
      "zstd" = "zstd --no-progress --threads=$NIX_BUILD_CORES -${toString compression.level}";

      "zstd-seekable" =
        "zeekstd --no-progress --frame-size 2M --compression-level ${toString compression.level}";
    }
    ."${compression.algorithm}";
in
stdenvNoCC.mkDerivation (
  finalAttrs:
  (
    if (version != null) then
      {
        inherit version;
        pname = name;
      }
    else
      { inherit name; }
  )
  // {
    inherit finalPartitions definitionsDirectory;
    __structuredAttrs = true;

    buildPhase = ''
      runHook preBuild

      echo "Building image with systemd-repart..."
      unshare --map-root-user fakeroot systemd-repart \
        ''${systemdRepartFlags[@]} \
        ${baseName}.raw \
        | tee repart-output.json

      runHook postBuild
    '';

    doCheck = false;
    dontConfigure = true;
    dontFixup = true;
    dontUnpack = true;
    env = mkfsEnv;
    # relative path to the repart definitions that are read by systemd-repart
    finalRepartDefinitions = "repart.d";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
    ''
    # Compression is implemented in the same derivation as opposed to in a
    # separate derivation to allow users to save disk space. Disk images are
    # already very space intensive so we want to allow users to mitigate this.
    + lib.optionalString compression.enable ''
      for f in ${baseName}*; do
        echo "Compressing $f with ${compression.algorithm}..."
        # Keep the original file when compressing and only delete it afterwards
        ${compressionCommand} $f && rm $f
      done
    ''
    + ''
      mv -v repart-output.json ${baseName}* $out

      runHook postInstall
    '';

    nativeBuildInputs = [
      systemd
      util-linux
      fakeroot
    ]
    ++ lib.optionals (compression.enable) [
      compressionPkg
    ]
    ++ fileSystemTools;

    partitionsJSON = builtins.toJSON finalAttrs.finalPartitions;

    passthru = {
      inherit amendRepartDefinitions;
    };

    patchPhase = ''
      runHook prePatch

      amendedRepartDefinitionsDir=$(${amendRepartDefinitions} <(echo "$partitionsJSON") $definitionsDirectory)
      ln -vs $amendedRepartDefinitionsDir $finalRepartDefinitions

      runHook postPatch
    '';

    systemdRepartFlags = [
      "--architecture=${systemdArch}"
      "--dry-run=no"
      "--size=${imageSize}"
      "--definitions=${finalAttrs.finalRepartDefinitions}"
      "--split=${lib.boolToString split}"
      "--json=pretty"
    ]
    ++ lib.optionals (seed != null) [
      "--seed=${seed}"
    ]
    ++ lib.optionals createEmpty [
      "--empty=create"
    ]
    ++ lib.optionals (sectorSize != null) [
      "--sector-size=${toString sectorSize}"
    ];

    # the image will be self-contained so we can drop references
    # to the closure that was used to build it
    unsafeDiscardReferences.out = true;
  }
)
