{
  lib,
  # build-system
  build,
  buildPythonPackage,
  config,
  cudaPackages,
  meson-python,
  nixl,
  # dependencies
  numpy,
  pybind11,
  pytest,
  python,
  pyyaml,
  setuptools,
  torch,
  types-pyyaml,
  cudaSupport ? config.cudaSupport,
}:

buildPythonPackage.override { inherit (nixl) stdenv; } (finalAttrs: {
  inherit (nixl)
    pname
    version
    src
    __structuredAttrs
    strictDeps
    nativeBuildInputs
    dontUseCmakeConfigure
    buildInputs
    mesonFlags
    ;

  postPatch = (nixl.postPatch or "") + ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        '"patchelf",' \
        "" \
      --replace-fail \
        "torch==2.11.*" \
        "torch"
  '';

  # No tests we can run in the sandbox
  doCheck = false;

  # Install the `nixl` shim module (re-exports nixl_cu{12,13}).
  # Upstream builds this as a separate wheel via `uv build` (nixl-meta), but that doesn't work in
  # the sandbox.
  postInstall = ''
    install -Dm644 \
      src/bindings/python/nixl-meta/nixl/__init__.py \
      "$out/${python.sitePackages}/nixl/__init__.py"
  '';

  build-system = [
    build
    meson-python
    pybind11
    pytest
    pyyaml
    setuptools
    torch
    types-pyyaml
  ];

  dependencies = [
    numpy
    torch
  ];

  dontUseMesonConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "nixl"
  ]
  ++ lib.optionals cudaSupport [
    "nixl_cu${cudaPackages.cudaMajorVersion}"
  ];

  meta = nixl.meta // {
    description = "Python API for nixl";
  };
})
