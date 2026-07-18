{
  lib,
  buildPythonPackage,
  cmake,
  cython,
  memory-profiler,
  ninja,
  pathspec,
  pocketsphinx,
  pytestCheckHook,
  scikit-build-core,
  sounddevice,
}:

buildPythonPackage rec {
  inherit (pocketsphinx) version src;
  pname = "pocketsphinx";
  buildInputs = [ pocketsphinx ];
  env.CMAKE_ARGS = lib.cmakeBool "USE_INSTALLED_POCKETSPHINX" true;

  nativeCheckInputs = [
    memory-profiler
    pytestCheckHook
  ];

  build-system = [
    cmake
    cython
    ninja
    pathspec
    scikit-build-core
  ];

  dependencies = [ sounddevice ];
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pocketsphinx" ];

  meta = {
    description = "Small speech recognizer";
    homepage = "https://github.com/cmusphinx/pocketsphinx";
    changelog = "https://github.com/cmusphinx/pocketsphinx/blob/v${version}/NEWS";

    license =
      with lib.licenses;
      AND [
        bsd2
        bsd3
        mit
      ];

    maintainers = with lib.maintainers; [ jopejoe1 ];
  };
}
