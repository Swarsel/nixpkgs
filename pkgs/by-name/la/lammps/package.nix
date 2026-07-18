{
  lib,
  stdenv,
  fetchFromGitHub,
  autoAddDriverRunpath,
  blas,
  cmake,
  fftw,
  gzip,
  lapack,
  libpng,
  mpich,
  pkg-config,
  python3,
  # Extra `buildInputs` - meant for packages that require more inputs
  extraBuildInputs ? [ ],
  # Extra cmakeFlags to add as "-D${attr}=${value}"
  extraCmakeFlags ? { },
  # Available list of packages can be found near here:
  #
  # - https://github.com/lammps/lammps/blob/develop/cmake/CMakeLists.txt#L222
  # - https://docs.lammps.org/Build_extras.html
  packages ? {
    ASPHERE = true;
    BODY = true;
    CLASS2 = true;
    COLLOID = true;
    COMPRESS = true;
    CORESHELL = true;
    DIPOLE = true;
    GRANULAR = true;
    KSPACE = true;
    MANYBODY = true;
    MC = true;
    MISC = true;
    ML-SNAP = true;
    MOLECULE = true;
    MPIIO = true;
    OPT = true;
    PERI = true;
    PYTHON = true;
    QEQ = true;
    REAXFF = true;
    REPLICA = true;
    RIGID = true;
    SHOCK = true;
    SRD = true;
  },
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lammps";
  # LAMMPS has weird versioning convention. Updates should go smoothly with:
  # nix-update --commit lammps --version-regex 'stable_(.*)'
  version = "22Jul2025_update4";

  src = fetchFromGitHub {
    owner = "lammps";
    repo = "lammps";
    tag = "stable_${finalAttrs.version}";
    hash = "sha256-QH63nh7J3NjfdfpN7J96Q+9ZGqj8cA0YwEmgTuBbGmg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    # Although not always needed, it is needed if cmakeFlags include
    # GPU_API=cuda, and it doesn't users that don't enable the GPU package.
    autoAddDriverRunpath
  ]
  ++ lib.optionals packages.PYTHON [
    python3
  ]
  ++ lib.optionals packages.MPIIO [
    mpich
  ];

  buildInputs = [
    fftw
    libpng
    blas
    lapack
    gzip
  ]
  ++ lib.optionals packages.PYTHON [ python3 ]
  ++ extraBuildInputs;

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
  ]
  ++ (lib.mapAttrsToList (n: v: lib.cmakeBool "PKG_${n}" v) packages)
  ++ (lib.mapAttrsToList (n: v: "-D${n}=${v}") extraCmakeFlags);

  preConfigure = ''
    cd cmake
  '';

  postInstall = ''
    # For backwards compatibility
    ln -s $out/bin/lmp $out/bin/lmp_serial
    # Install vim and neovim plugin
    install -Dm644 ../../tools/vim/lammps.vim $out/share/vim-plugins/lammps/syntax/lammps.vim
    install -Dm644 ../../tools/vim/filetype.vim $out/share/vim-plugins/lammps/ftdetect/lammps.vim
    mkdir -p $out/share/nvim
    ln -s $out/share/vim-plugins/lammps $out/share/nvim/site
  '';

  __structuredAttrs = true;

  passthru = {
    inherit packages;
    inherit extraCmakeFlags;
    inherit extraBuildInputs;
  };

  meta = {
    description = "Classical Molecular Dynamics simulation code";

    longDescription = ''
      LAMMPS is a classical molecular dynamics simulation code designed to
      run efficiently on parallel computers. It was developed at Sandia
      National Laboratories, a US Department of Energy facility, with
      funding from the DOE. It is an open-source code, distributed freely
      under the terms of the GNU Public License (GPL).
    '';

    homepage = "https://www.lammps.org";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      costrouc
      doronbehar
    ];

    platforms = lib.platforms.linux;
    mainProgram = "lmp";
    # compiling lammps with 64 bit support blas and lapack might cause runtime
    # segfaults. In anycase both blas and lapack should have the same #bits
    # support.
    broken = (blas.isILP64 && lapack.isILP64);
  };
})
