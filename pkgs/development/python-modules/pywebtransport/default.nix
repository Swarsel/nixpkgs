{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  clang,
  llvmPackages,
  msgpack,
  pkg-config,
  protobuf,
  psutil,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  rustPlatform,
  types-psutil,
  uvloop,
}:

buildPythonPackage (finalAttrs: {
  pname = "pywebtransport";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "wtransport";
    repo = "pywebtransport";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DKvWSu2ufoIsBODNfFbM9JUtY81mmUISmD+qMQ6UVDI=";
  };

  nativeBuildInputs = [
    llvmPackages.clang
    llvmPackages.libclang.lib
    pkg-config
  ];

  env.LD_LIBRARY_PATH = "${llvmPackages.libclang.lib}/lib:${lib.getLib clang}/lib";
  env.LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  nativeCheckInputs = [
    psutil
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
    types-psutil
    uvloop
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  preCheck = ''
    cp -v $out/lib/python*/site-packages/pywebtransport/_wtransport*.so src/pywebtransport/
  '';

  build-system = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    cargoRoot = "crates";
    hash = "sha256-gplelmBqntws+64DmjOZ5xbo3L/f+3+oasi5qLXT1pg=";
  };

  disabledTestPaths = [
    # Tests require network access
    "tests/e2e"
  ];

  optional-dependencies = {
    msgpack = [ msgpack ];
    protobuf = [ protobuf ];
  };

  prePatch = ''
    # maturin can't find the file
    ln -s crates/Cargo.lock Cargo.lock || true
  '';

  pyproject = true;
  pythonImportsCheck = [ "pywebtransport" ];

  meta = {
    description = "WebTransport stack for Python";
    homepage = "https://github.com/wtransport/pywebtransport";
    changelog = "https://github.com/wtransport/pywebtransport/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
