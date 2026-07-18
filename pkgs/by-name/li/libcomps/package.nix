{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  cmake,
  doxygen,
  expat,
  libxml2,
  python3,
  sphinx,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcomps";
  version = "0.1.24";

  src = fetchFromGitHub {
    owner = "rpm-software-management";
    repo = "libcomps";
    rev = finalAttrs.version;
    hash = "sha256-O60+k3ZnSfP+wFI55s/WfgrPbvu52uXZh88Ebg3Nf+c=";
  };

  outputs = [
    "out"
    "dev"
    "py"
  ];

  patches = [
    ./fix-python-install-dir.patch
  ];

  postPatch = ''
    substituteInPlace libcomps/src/python/src/CMakeLists.txt \
      --replace "@PYTHON_INSTALL_DIR@" "$out/${python3.sitePackages}"
  '';

  nativeBuildInputs = [
    check
    cmake
    doxygen
    python3
    sphinx
  ];

  buildInputs = [
    expat
    libxml2
    zlib
  ];

  postFixup = ''
    ls $out/lib
    moveToOutput "lib/${python3.libPrefix}" "$py"
  '';

  cmakeDir = "libcomps";
  dontUseCmakeBuildDir = true;

  meta = {
    description = "Comps XML file manipulation library";
    homepage = "https://github.com/rpm-software-management/libcomps";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ katexochen ];
    platforms = lib.platforms.unix;
  };
})
