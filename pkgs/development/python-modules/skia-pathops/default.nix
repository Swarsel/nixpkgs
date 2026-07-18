{
  lib,
  stdenv,
  buildPythonPackage,
  cctools,
  cython,
  fetchPypi,
  gn,
  isPyPy,
  ninja,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  xcodebuild,
}:

buildPythonPackage rec {
  pname = "skia-pathops";
  version = "0.9.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-S22EWfb0ppKCyyb8oMK7CzIcxYqb+cxleaUqOR7cAxk=";
    pname = "skia_pathops";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "build_cmd = [sys.executable, build_skia_py, build_dir]" \
        'build_cmd = [sys.executable, build_skia_py, "--no-fetch-gn", "--no-virtualenv", "--gn-path", "${gn}/bin/gn", build_dir]'
  ''
  + lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) ''
    substituteInPlace src/cpp/skia-builder/skia/gn/skia/BUILD.gn \
      --replace "-march=armv7-a" "-march=armv8-a" \
      --replace "-mfpu=neon" "" \
      --replace "-mthumb" ""
    substituteInPlace src/cpp/skia-builder/skia/src/core/SkOpts.cpp \
      --replace "defined(SK_CPU_ARM64)" "0"
  ''
  +
    lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) # old compiler?
      ''
        patch -p1 <<EOF
        --- a/src/cpp/skia-builder/skia/include/private/base/SkTArray.h
        +++ b/src/cpp/skia-builder/skia/include/private/base/SkTArray.h
        @@ -492 +492 @@:
        -    static constexpr int kMaxCapacity = SkToInt(std::min(SIZE_MAX / sizeof(T), (size_t)INT_MAX));
        +    static constexpr int kMaxCapacity = SkToInt(std::min<size_t>(SIZE_MAX / sizeof(T), (size_t)INT_MAX));
        EOF
      '';

  nativeBuildInputs = [
    ninja
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools.libtool
    xcodebuild
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cython
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pathops" ];

  meta = {
    description = "Python access to operations on paths using the Skia library";
    homepage = "https://github.com/fonttools/skia-pathops";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    # "The Skia team is not endian-savvy enough to support big-endian CPUs."
    badPlatforms = lib.platforms.bigEndian;
    # ERROR at //gn/BUILDCONFIG.gn:87:14: Script returned non-zero exit code.
    broken = isPyPy;
  };
}
