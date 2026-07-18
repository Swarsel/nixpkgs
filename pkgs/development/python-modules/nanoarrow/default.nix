{
  lib,
  buildPythonPackage,
  # build-system
  cython,
  meson,
  meson-python,
  nanoarrow-c,
  # nativeBuildInputs
  pkg-config,
  pytestCheckHook,
  # buildInputs
  zlib,
  zstd-c,
}:

buildPythonPackage (finalAttrs: {
  inherit (nanoarrow-c)
    pname
    version
    src
    postPatch
    ;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zlib
    zstd-c
  ];

  mesonFlags = [
    # Use system zstd instead of the meson wrap
    (lib.mesonOption "force_fallback_for" "flatcc")
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    cython
    meson
    meson-python
  ];

  pyproject = true;
  pythonImportsCheck = [ "nanoarrow" ];
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = nanoarrow-c.meta // {
    description = "Python bindings to the nanoarrow C library";
    homepage = "https://github.com/apache/arrow-nanoarrow/tree/main/python";

    maintainers = with lib.maintainers; [
      GaetanLepage
      doronbehar
    ];
  };
})
