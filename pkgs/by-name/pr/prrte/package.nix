{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  flex,
  gitMinimal,
  hwloc,
  libevent,
  libtool,
  perl,
  pkg-config,
  pmix,
  python3,
  removeReferencesTo,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prrte";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "openpmix";
    repo = "prrte";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FO2dFqvJ3Ahc7rE2gAiQhmM5GTc7LJ8nE4y5fe+FgDg=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs ./autogen.pl ./config

    # This is needed for multi-node jobs.
    # mpirun/srun/prterun does not have "prted" in its path unless
    # it is actively pulled in. Hard-coding the nix store path
    # as a default universally solves this issue.
    substituteInPlace src/runtime/prte_mca_params.c --replace-fail \
      "prte_launch_agent = \"prted\"" "prte_launch_agent = \"$out/bin/prted\""
  '';

  nativeBuildInputs = [
    removeReferencesTo
    perl
    python3
    autoconf
    automake
    libtool
    flex
    gitMinimal
    pkg-config
  ];

  buildInputs = [
    libevent
    hwloc
    zlib
    pmix
  ];

  # Setting this manually, required for RiscV cross-compile
  configureFlags = [
    "--with-pmix=${lib.getDev pmix}"
    "--with-pmix-libdir=${lib.getLib pmix}/lib"
  ];

  preConfigure = ''
    ./autogen.pl
    patchShebangs --build ./src/util/prte-convert-help.py
  '';

  postInstall = ''
    moveToOutput "bin/prte_info" "''${!outputDev}"
    moveToOutput "bin/prte-info" "''${!outputDev}"
    # Fix a broken symlink, created due to FHS assumptions
    rm "$out/bin/pcc"
    ln -s ${lib.getDev pmix}/bin/pmixcc "''${!outputDev}"/bin/pcc

    remove-references-to -t "''${!outputDev}" $(readlink -f $out/lib/libprrte${stdenv.hostPlatform.extensions.library})
  '';

  enableParallelBuilding = true;

  meta = {
    description = "PMIx Reference Runtime Environment";
    homepage = "https://docs.prrte.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ markuskowa ];
    platforms = lib.platforms.unix;
  };
})
