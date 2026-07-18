{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  bash,
  coreutils,
  curl,
  fetchpatch,
  libdeflate,
  python3Packages,
  zlib,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "flye";
  version = "2.9.6";

  src = fetchFromGitHub {
    owner = "mikolmogorov";
    repo = "flye";
    tag = finalAttrs.version;
    hash = "sha256-ZdrAxPKY3+HJ388tGCdpDcvW70mJ5wd4uOUkuufyqK8=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-Ny2daPt8eYOKnwZ6bdBoCcFWhe9eiIHF4vJU/occwU0=";
      # https://github.com/mikolmogorov/Flye/pull/691
      name = "aarch64-fix.patch";
      url = "https://github.com/mikolmogorov/Flye/commit/e4dcc3fdf0fa1430a974fcd7da31b03ea642df9b.patch";
    })
  ];

  postPatch = ''
    substituteInPlace flye/polishing/alignment.py \
      --replace-fail "/bin/bash" "${lib.getExe bash}"
  '';

  buildInputs = [
    zlib
    curl
    libdeflate
  ];

  propagatedBuildInputs = [ coreutils ];

  nativeCheckInputs = [
    addBinToPathHook
    python3Packages.pytestCheckHook
  ];

  build-system = [ python3Packages.setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "flye" ];

  meta = {
    description = "De novo assembler for single molecule sequencing reads using repeat graphs";
    homepage = "https://github.com/mikolmogorov/Flye";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ assistant ];
    mainProgram = "flye";
  };
})
