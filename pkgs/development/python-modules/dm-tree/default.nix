{
  lib,
  fetchFromGitHub,
  # buildInputs
  abseil-cpp,
  # dependencies
  absl-py,
  attrs,
  buildPythonPackage,
  # nativeBuildInputs
  cmake,
  numpy,
  pybind11,
  # build-system
  setuptools,
  wrapt,
}:
buildPythonPackage (finalAttrs: {
  pname = "dm-tree";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "deepmind";
    repo = "tree";
    tag = finalAttrs.version;
    hash = "sha256-L1DOwgJriFoS0rf6g+f3qcw94Q/ia4N6kZ1ai6F/Qng=";
  };

  # Allows to forward cmake args through the conventional `cmakeFlags`
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail \
        "cmake_args = [" \
        'cmake_args = [ *os.environ.get("cmakeFlags", "").split(),'
  '';

  nativeBuildInputs = [
    cmake
    pybind11
  ];

  buildInputs = [
    abseil-cpp
    pybind11
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_ABSEIL" true)
    (lib.cmakeBool "USE_SYSTEM_PYBIND11" true)
  ];

  build-system = [ setuptools ];

  # It is unclear whether those are runtime dependencies or simply test dependencies
  # https://github.com/google-deepmind/tree/issues/127
  dependencies = [
    absl-py
    attrs
    numpy
    wrapt
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "tree" ];

  meta = {
    description = "Python library for working with nested data structures";
    homepage = "https://github.com/deepmind/tree";
    changelog = "https://github.com/google-deepmind/tree/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      samuela
      ndl
    ];
  };
})
