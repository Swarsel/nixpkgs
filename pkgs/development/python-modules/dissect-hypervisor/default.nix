{
  lib,
  fetchFromGitHub,
  backports-zstd,
  buildPythonPackage,
  defusedxml,
  dissect-cstruct,
  dissect-util,
  fetchpatch2,
  pycryptodome,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "dissect-hypervisor";
  version = "3.21";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.hypervisor";
    tag = finalAttrs.version;
    hash = "sha256-T6dv8TtGTwjOVoGplgBJgRmFRst4Q0EMYgPheGSAEU4=";
    fetchLFS = true;
  };

  patches = [
    # Fix vmtar compat with python 3.13.13+ tarfile refactor.
    (fetchpatch2 {
      excludes = [ "tests/util/test_vmtar.py" ];
      hash = "sha256-Ot0rV1j+yQrXi7v1ARX+Pamnbr+/Q7T1YidY80QdgDo=";
      url = "https://github.com/fox-it/dissect.hypervisor/commit/8baa8f6ac1ae9a7cfd99095472d9f8e933d290f5.patch?full_index=1";
    })
  ];

  postPatch = ''
    substituteInPlace tests/util/test_vmtar.py \
      --replace-fail '"test/file1",' '"test", "test/file1",'
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    defusedxml
    dissect-cstruct
    dissect-util
  ];

  disabledTests = [
    # Read error
    "test_vmtar"
  ];

  optional-dependencies = {
    full = [
      backports-zstd
      pycryptodome
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dissect.hypervisor" ];

  meta = {
    description = "Dissect module implementing parsers for various hypervisor disk, backup and configuration files";
    homepage = "https://github.com/fox-it/dissect.hypervisor";
    changelog = "https://github.com/fox-it/dissect.hypervisor/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
