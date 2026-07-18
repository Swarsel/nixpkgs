{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  cmake,
  hdf5,
  nix-update-script,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kallisto";
  version = "0.51.1";

  src = fetchFromGitHub {
    owner = "pachterlab";
    repo = "kallisto";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hfdeztEyHvuOnLS71oSv8sPqFe2UCX5KlANqrT/Gfx8=";
  };

  patches = [
    # https://github.com/pmelsted/bifrost/pull/18
    ./bifrost-fix-datastorage-sz_link-typo.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt ext/bifrost/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    autoconf
    cmake
  ];

  buildInputs = [
    hdf5
    zlib
  ];

  cmakeFlags = [ "-DUSE_HDF5=ON" ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = false;
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Near-optimal quantification of transcripts from RNA-seq data";

    longDescription = ''
      kallisto is a program for quantifying abundances of transcripts
      from RNA sequencing data, or more generally of target sequences
      using high-throughput sequencing reads. It is based on the novel
      idea of pseudoalignment for rapidly determining the
      compatibility of reads with targets, without the need for
      alignment.
    '';

    homepage = "https://pachterlab.github.io/kallisto";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.arcadio ];
    platforms = lib.platforms.linux;
    mainProgram = "kallisto";
  };
})
