{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  mpi,
  nix-update-script,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hp2p";
  version = "4.2";

  src = fetchFromGitHub {
    owner = "cea-hpc";
    repo = "hp2p";
    tag = finalAttrs.version;
    hash = "sha256-KuDf1VhLQRDDY3NZaNaHDVGipLmB8+1K36/W1fKnno0=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    python3Packages.wrapPython
  ];

  buildInputs = [
    mpi
  ]
  ++ (with python3Packages; [
    python
    plotly
  ]);

  preConfigure = ''
    patchShebangs autogen.sh
    ./autogen.sh
    export CC=mpicc
    export CXX=mpic++
  '';

  postInstall = ''
    wrapPythonPrograms
  '';

  enableParallelBuilding = true;
  pythonPath = (with python3Packages; [ plotly ]);

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "MPI based benchmark for network diagnostics";
    homepage = "https://github.com/cea-hpc/hp2p";
    changelog = "https://github.com/cea-hpc/hp2p/releases/tag/${finalAttrs.version}";
    license = lib.licenses.cecill-c;
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.unix;

    badPlatforms = [
      # hp2p_algo_cpp.cpp:38:10: error: no member named 'random_shuffle' in namespace 'std'
      lib.systems.inspect.patterns.isDarwin
    ];

    mainProgram = "hp2p.exe";
  };
})
