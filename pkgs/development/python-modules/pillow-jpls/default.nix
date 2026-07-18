{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  charls,
  cmake,
  eigen,
  fmt,
  ninja,
  numpy,
  pathspec,
  pillow,
  pybind11,
  pyproject-metadata,
  pytestCheckHook,
  scikit-build-core,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pillow-jpls";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "planetmarshall";
    repo = "pillow-jpls";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Rc4/S8BrYoLdn7eHDBaoUt1Qy+h0TMAN5ixCAuRmfPU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"conan~=2.0.16",' "" \
      --replace-fail '"pybind11~=2.11.1",' '"pybind11",'
  '';

  buildInputs = [
    charls
    eigen
    fmt
  ];

  cmakeFlags = [
    "--preset=sysdeps"
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  # Prevent importing from build during test collection:
  preCheck = "rm -rf pillow_jpls";

  build-system = [
    cmake
    ninja
    pybind11
    scikit-build-core
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    pillow
    pathspec
    pyproject-metadata
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pillow_jpls" ];

  meta = {
    description = "JPEG-LS plugin for the Python Pillow library";
    homepage = "https://github.com/planetmarshall/pillow-jpls";
    changelog = "https://github.com/planetmarshall/pillow-jpls/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
