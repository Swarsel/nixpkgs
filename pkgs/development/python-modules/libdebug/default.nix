{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  elfutils,
  libdwarf,
  libiberty,
  nanobind,
  ninja,
  pkg-config,
  prompt-toolkit,
  psutil,
  pyelftools,
  requests,
  scikit-build-core,
  typing-extensions,
  writableTmpDirAsHomeHook,
  zlib,
  zstd,
}:

buildPythonPackage (finalAttrs: {
  pname = "libdebug";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "libdebug";
    repo = "libdebug";
    tag = finalAttrs.version;
    hash = "sha256-J0ETzqAGufsZyW+XDhJCKwX1rrmDBwlAicvBb1AAiIQ=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
  ];

  buildInputs = [
    libdwarf
    elfutils
    zstd
    libiberty
    zlib
  ];

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  build-system = [ scikit-build-core ];

  dependencies = [
    psutil
    pyelftools
    requests
    prompt-toolkit
    nanobind
    typing-extensions
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "libdebug" ];

  meta = {
    description = "Programmatic debugging of userland Linux binaries";
    homepage = "https://github.com/libdebug/libdebug";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mrsmoer ];
  };
})
