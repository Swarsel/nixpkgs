{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  bash,
  bison,
  coreutils,
  flex,
  gdb,
  git,
  help2man,
  makeWrapper,
  numactl,
  perl,
  python3,
  systemc,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "verilator";
  version = "5.050";

  src = fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZOwBBbVNP0PaYUvrjdvbWu88fZOZ6IJ8BHAiajcOjP8=";
  };

  postPatch = ''
    patchShebangs bin/* src/* nodist/* docs/bin/* examples/xml_py/* \
    test_regress/{driver.py,t/*.{pl,pf}} \
    test_regress/t/t_a1_first_cc.py \
    test_regress/t/t_a2_first_sc.py \
    ci/* ci/docker/run/* ci/docker/run/hooks/* ci/docker/buildenv/build.sh
    # verilator --gdbbt uses /bin/sh to test if gdb works.
    substituteInPlace bin/verilator --replace-fail "/bin/sh" "${bash}/bin/sh"
  '';

  nativeBuildInputs = [
    makeWrapper
    flex
    bison
    autoconf
    help2man
    git
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    gdb
  ];

  buildInputs = [
    perl
    systemc
    (python3.withPackages (
      pp: with pp; [
        distro
      ]
    ))
    # ccache
  ];

  env = {
    SYSTEMC_INCLUDE = "${lib.getDev systemc}/include";
    SYSTEMC_LIBDIR = "${lib.getLib systemc}/lib";
    # Verilator gets the version from this environment variable
    # if it can't do git describe while building.
    VERILATOR_SRC_VERSION = "v${finalAttrs.version}";
  };

  preConfigure = "autoconf";
  doCheck = true;

  nativeCheckInputs = [
    which
    coreutils
    # cmake
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    numactl
  ];

  # grep '^#!/' -R . | grep -v /nix/store | less
  # (in nix-shell after patchPhase)
  # This is needed to ensure that the check phase can find the verilator_bin_dbg.
  preCheck = ''
    export PATH=$PWD/bin:$PATH
  '';

  checkTarget = "test";
  enableParallelBuilding = true;

  meta = {
    description = "Fast and robust (System)Verilog simulator/compiler and linter";
    homepage = "https://www.veripool.org/verilator";
    changelog = "https://github.com/verilator/verilator/blob/${finalAttrs.src.tag}/Changes";

    license = with lib.licenses; [
      lgpl3Only
      artistic2
    ];

    maintainers = with lib.maintainers; [
      thoughtpolice
    ];

    platforms = lib.platforms.unix;
  };
})
