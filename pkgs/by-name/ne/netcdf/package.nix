{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  curl, # for DAP
  hdf5,
  libaec,
  libxml2,
  libzip,
  m4,
  removeReferencesTo,
  unzip,
  zstd,
  szipSupport ? hdf5.szipSupport,
}:

let
  inherit (hdf5) mpiSupport mpi;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "netcdf" + lib.optionalString mpiSupport "-mpi";
  version = "4.9.3";

  src = fetchurl {
    url = "https://downloads.unidata.ucar.edu/netcdf-c/${finalAttrs.version}/netcdf-c-${finalAttrs.version}.tar.gz";
    hash = "sha256-pHQUmETmFEVmZz+s8Jf+olPchDw3vAp9PeBH3Irdpd0=";
  };

  postPatch = ''
    patchShebangs .

    # this test requires the net
    for a in ncdap_test/Makefile.am ncdap_test/Makefile.in; do
      substituteInPlace $a --replace testurl.sh " "
    done

    # Prevent building the tests from prepending `#!/bin/bash` and wiping out the patched shenbangs.
    substituteInPlace nczarr_test/Makefile.in \
      --replace '#!/bin/bash' '${stdenv.shell}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    m4
    removeReferencesTo
    libxml2 # xml2-config
  ];

  buildInputs = [
    curl
    hdf5
    libxml2
    bzip2
    libzip
    zstd
  ]
  ++ lib.optional szipSupport libaec
  ++ lib.optional mpiSupport mpi;

  configureFlags = [
    "--enable-netcdf-4"
    "--enable-dap"
    "--enable-shared"
    "--disable-dap-remote-tests"
    "--with-plugin-dir=${placeholder "out"}/lib/hdf5-plugins"
  ]
  ++ (lib.optionals mpiSupport [
    "--enable-parallel-tests"
    "CC=${lib.getDev mpi}/bin/mpicc"
  ]);

  env.NIX_CFLAGS_COMPILE =
    # Suppress incompatible function pointer errors when building with newer versions of clang 16.
    # tracked upstream here: https://github.com/Unidata/netcdf-c/issues/2715
    lib.optionalString stdenv.cc.isClang "-Wno-error=incompatible-function-pointer-types";

  doCheck = !mpiSupport;
  nativeCheckInputs = [ unzip ];

  preCheck = ''
    export HOME=$TEMP
  '';

  postFixup = ''
    remove-references-to -t ${stdenv.cc} "$(readlink -f $out/lib/libnetcdf.settings)"
  '';

  disallowedReferences = [ stdenv.cc ];
  enableParallelBuilding = true;

  passthru = {
    inherit mpiSupport mpi;
  };

  meta = {
    description = "Libraries for the Unidata network Common Data Format";
    homepage = "https://www.unidata.ucar.edu/software/netcdf/";
    changelog = "https://docs.unidata.ucar.edu/netcdf-c/${finalAttrs.version}/RELEASE_NOTES.html";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      doronbehar
    ];

    platforms = lib.platforms.unix;
  };
})
