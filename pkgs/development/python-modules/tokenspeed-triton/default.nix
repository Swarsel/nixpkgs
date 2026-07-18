{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  nanobind,
  ninja,
  nlohmann_json,
  pythonAtLeast,
  setuptools,
  # buildInputs
  tokenspeed-triton-llvm,
  # nativeBuildInputs
  writableTmpDirAsHomeHook,
  zlib,
}:
buildPythonPackage (finalAttrs: {
  pname = "tokenspeed-triton";
  version = "3.7.10.post20260531";

  src = fetchFromGitHub {
    owner = "lightseekorg";
    repo = "triton";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xsV63z2NtB5BM0rF0J+cnMH2RYzoWkpsSXHQI2nIEdQ=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "TRITON_VERSION = " 'TRITON_VERSION = "${finalAttrs.version}" # '

    sed -i '/def is_git_repo()/a\\    return False' setup.py

    substituteInPlace pyproject.toml \
      --replace-fail "cmake>=3.20,<4.0" "cmake>=3.20" \
      --replace-fail "nanobind==2.10.2" "nanobind>=2.10.2"
  '';

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    zlib
  ];

  # https://github.com/lightseekorg/triton/blob/v3.7.10.post20260531/.github/workflows/wheels.yml#L109-L117
  env = {
    JSON_SYSPATH = nlohmann_json;
    LLVM_SYSPATH = tokenspeed-triton-llvm;
    NIX_CFLAGS_COMPILE = "-Wno-stringop-overflow";
    TRITON_BUILD_PROTON = false;
    TRITON_BUILD_RELEASE = true;
    TRITON_OFFLINE_BUILD = true;
    TRITON_STABLE_ABI = pythonAtLeast "3.12";
  };

  # tests import triton instead of tokenspeed_triton
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    cmake
    nanobind
    ninja
    setuptools
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "tokenspeed_triton"
  ];

  meta = {
    description = "Language and compiler for custom Deep Learning operations";
    homepage = "https://github.com/lightseekorg/triton";
    changelog = "https://github.com/lightseekorg/triton/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    downloadPage = "https://pypi.org/project/tokenspeed-triton/#files";
  };
})
