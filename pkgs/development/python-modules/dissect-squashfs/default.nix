{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  lz4,
  python-lzo,
  setuptools,
  setuptools-scm,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "dissect-squashfs";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.squashfs";
    tag = finalAttrs.version;
    hash = "sha256-p+8MKpjAq09jTrlTaA8zSf1wMYzAHtydm5c8RICCAOQ=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  optional-dependencies = {
    full = [
      lz4
      python-lzo
      zstandard
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dissect.squashfs" ];

  meta = {
    description = "Dissect module implementing a parser for the SquashFS file system";
    homepage = "https://github.com/fox-it/dissect.squashfs";
    changelog = "https://github.com/fox-it/dissect.squashfs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
