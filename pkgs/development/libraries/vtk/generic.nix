{
  sourceSha256,
  version,
  patches ? [ ],
}:
{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  adios2,
  alembic,
  boost,
  c-blosc,
  catalyst,
  # io modules
  cgns,
  cli11,
  cmake,
  double-conversion,
  eigen,
  expat,
  exprtk,
  ffmpeg,
  fontconfig,
  freetype,
  gdal,
  gl2ps,
  hdf5,
  imath,
  jsoncpp,
  libGL,
  libarchive,
  libharu,
  libjpeg,
  liblas,
  libmysqlclient,
  libogg,
  libpng,
  libpq,
  libtheora,
  libtiff,
  libx11,
  libxcursor,
  libxfixes,
  libxml2,
  libxrender,
  llvmPackages,
  # common data libraries
  lz4,
  mpi,
  netcdf,
  newScope,
  nlohmann_json,
  # threading
  onetbb,
  onnxruntime,
  opencascade-occt,
  openslide,
  # filters
  openturns,
  openusd,
  openvdb,
  pdal,
  pkg-config,
  proj,
  pugixml,
  python3Packages,
  qt6,
  sqlite,
  # passthru.tests
  testers,
  # common dependencies
  tk,
  unixodbc,
  utf8cpp,
  verdict,
  # rendering
  viskores,
  xz,
  zlib,
  # To avoid conflicts between the propagated vtkPackages.hdf5
  # and the input hdf5 used by most downstream packages,
  # we set mpiSupport to false by default.
  mpiSupport ? false,
  pythonSupport ? false,
  # custom options
  withQt6 ? false,
}:
let
  vtkPackages = lib.makeScope newScope (self: {
    inherit
      mpi
      mpiSupport
      python3Packages
      pythonSupport
      ;

    adios2 = self.callPackage adios2.override { };
    catalyst = self.callPackage catalyst.override { };
    cgns = self.callPackage cgns.override { };
    gdal = self.callPackage gdal.override { useMinimalFeatures = true; };

    hdf5 = hdf5.override {
      inherit mpi mpiSupport;
      cppSupport = !mpiSupport;
    };

    netcdf = self.callPackage netcdf.override { };
    # vtk fail to configure with openusd with materialX support
    # see https://github.com/AcademySoftwareFoundation/MaterialX/pull/2752
    openusd = openusd.override { withMaterialX = false; };
    pdal = self.callPackage pdal.override { };
    viskores = self.callPackage viskores.override { };
  });
  vtkBool = feature: bool: lib.cmakeFeature feature "${if bool then "YES" else "NO"}";
in
stdenv.mkDerivation (finalAttrs: {
  inherit version patches;
  pname = "vtk";

  src = fetchurl {
    url = "https://www.vtk.org/files/release/${lib.versions.majorMinor finalAttrs.version}/VTK-${finalAttrs.version}.tar.gz";
    hash = sourceSha256;
  };

  nativeBuildInputs = [
    cmake
    pkg-config # required for finding MySQl
  ]
  ++ lib.optionals pythonSupport [
    python3Packages.python
    python3Packages.pythonRecompileBytecodeHook
  ]
  ++ lib.optional (
    pythonSupport && stdenv.buildPlatform == stdenv.hostPlatform
  ) python3Packages.pythonImportsCheckHook;

  buildInputs = [
    liblas
    alembic
    imath
    c-blosc
    unixodbc
    libpq
    libmysqlclient
    ffmpeg
    opencascade-occt
    fontconfig
    openturns
    libarchive
    libGL
    openvdb
    vtkPackages.gdal
    vtkPackages.pdal
  ]
  ++ lib.optionals (lib.versionAtLeast finalAttrs.version "9.6.0") [
    vtkPackages.openusd
    onnxruntime
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libxfixes
    libxrender
    libxcursor
  ]
  ++ lib.optional withQt6 qt6.qttools
  ++ lib.optional mpiSupport mpi
  ++ lib.optional pythonSupport tk;

  # propagated by vtk-config.cmake
  propagatedBuildInputs = [
    eigen
    boost
    verdict
  ]
  ++ lib.optionals (lib.versionOlder finalAttrs.version "9.6.0") [
    double-conversion
  ]
  ++ [
    freetype
    lz4
    xz
    zlib
    expat
    exprtk
    pugixml
    jsoncpp
    libxml2
    utf8cpp
    nlohmann_json
    libjpeg
    libpng
    libtiff
    proj
    sqlite
    libogg
    libharu
    libtheora
    cli11
    openslide
    onetbb
    vtkPackages.hdf5
    vtkPackages.cgns
    vtkPackages.adios2
    vtkPackages.netcdf
    vtkPackages.catalyst
    vtkPackages.viskores
  ]
  ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libx11
    gl2ps
  ]
  # create meta package providing dist-info for python3Pacakges.vtk that common cmake build does not do
  ++ lib.optionals pythonSupport [
    (python3Packages.mkPythonMetaPackage {
      inherit (finalAttrs) pname version meta;

      dependencies =
        with python3Packages;
        [
          numpy
          wslink
          matplotlib
        ]
        ++ lib.optional mpiSupport (mpi4py.override { inherit mpi; });
    })
  ];

  cmakeFlags = [
    # During installPhase, keep rpath that came from target_link_libraries() of imported targets.
    # Typically libgeotiff,liblaszip propagated from liblas and libmariadb found by pkg-config.
    (lib.cmakeBool "CMAKE_INSTALL_RPATH_USE_LINK_PATH" true)
    # Required for locating the findOpenVDB.cmake module
    # TODO: Add a setup hook in openvdb to append CMAKE_MODULE_PATH to cmakeFlagsArray
    (lib.cmakeFeature "CMAKE_MODULE_PATH" "${lib.getDev openvdb}/lib/cmake/OpenVDB")
    (lib.cmakeFeature "CMAKE_INSTALL_BINDIR" "bin")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")

    # vtk common configure options
    (lib.cmakeBool "VTK_DISPATCH_SOA_ARRAYS" true)
    (lib.cmakeBool "VTK_ENABLE_CATALYST" true)
    (lib.cmakeBool "VTK_WRAP_SERIALIZATION" true)
    (lib.cmakeBool "VTK_BUILD_ALL_MODULES" true)
    (lib.cmakeBool "VTK_VERSIONED_INSTALL" false)
    (lib.cmakeBool "VTK_SMP_ENABLE_OPENMP" true)
    (lib.cmakeFeature "VTK_SMP_IMPLEMENTATION_TYPE" "TBB")

    # use system packages if possible
    (lib.cmakeBool "VTK_USE_EXTERNAL" true)
    (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_fast_float" false) # required version incompatible
    (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_pegtl" false) # required version incompatible
    (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_ioss" false) # missing in nixpkgs
    (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_token" false) # missing in nixpkgs
    (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_fmt" false) # prefer vendored fmt
    (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_scn" false) # missing in nixpkgs
    (lib.cmakeBool "VTK_MODULE_USE_EXTERNAL_VTK_gl2ps" stdenv.hostPlatform.isLinux) # external gl2ps causes failure linking to macOS OpenGL.framework

    # Rendering
    (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingRayTracing" false) # ospray
    (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingOpenXR" false) # openxr
    (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingOpenVR" false) # openvr
    (vtkBool "VTK_MODULE_ENABLE_VTK_RenderingAnari" false) # anari

    # withQt6
    (vtkBool "VTK_GROUP_ENABLE_Qt" withQt6)
    (lib.cmakeFeature "VTK_QT_VERSION" "Auto") # will search for Qt6 first

    # pythonSupport
    (lib.cmakeBool "VTK_USE_TK" pythonSupport)
    (vtkBool "VTK_GROUP_ENABLE_Tk" pythonSupport)
    (lib.cmakeBool "VTK_WRAP_PYTHON" pythonSupport)
    (lib.cmakeBool "VTK_BUILD_PYI_FILES" pythonSupport)
    (lib.cmakeFeature "VTK_PYTHON_VERSION" "3")

    # mpiSupport
    (lib.cmakeBool "VTK_USE_MPI" mpiSupport)
    (vtkBool "VTK_GROUP_ENABLE_MPI" mpiSupport)
  ];

  postFixup =
    # Remove thirdparty find module that have been provided in nixpkgs.
    ''
      rm -rf $out/lib/cmake/vtk/patches
      rm $out/lib/cmake/vtk/Find{EXPAT,Freetype,utf8cpp,LibXml2,FontConfig,TBB}.cmake
    ''
    # libvtkglad.so will find and load libGL.so at runtime.
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath ${lib.getLib libGL}/lib $out/lib/libvtkglad.so
    '';

  dontWrapQtApps = true;
  pythonImportsCheck = [ "vtk" ];
  requiredSystemFeatures = [ "big-parallel" ];

  passthru = {
    inherit
      pythonSupport
      mpiSupport
      ;

    tests = {
      cmake-config = testers.hasCmakeConfigModules {
        nativeBuildInputs = lib.optionals withQt6 [
          qt6.qttools
          qt6.wrapQtAppsHook
        ];

        moduleNames = [ "VTK" ];
        package = finalAttrs.finalPackage;
      };
    };

    vtkPackages = vtkPackages.overrideScope (
      final: prev: {
        vtk = finalAttrs.finalPackage;
      }
    );
  };

  meta = {
    description = "Open source libraries for 3D computer graphics, image processing and visualization";
    homepage = "https://www.vtk.org/";
    changelog = "https://docs.vtk.org/en/latest/release_details/${lib.versions.majorMinor finalAttrs.version}.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.unix;
  };
})
