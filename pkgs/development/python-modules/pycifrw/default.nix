{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  numpy,
  ply,
  prettytable,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycifrw";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "jamesrhester";
    repo = "pycifrw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b55+Vb2H/ADl586o5ch0X4HurwsbbgDg5XS5/8QhFZM=";
  };

  preBuild = ''
    make -C src Parsers
  '';

  # Requires external dictionaries (dics/DDLm/cif_mag.dic) which are not available
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    prettytable
    ply
  ];

  pyproject = true;
  pythonImportsCheck = [ "CifFile" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python library for reading and writing CIF files";
    homepage = "https://github.com/jamesrhester/pycifrw";
    changelog = "https://github.com/jamesrhester/pycifrw/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ fab ];
  };
})
