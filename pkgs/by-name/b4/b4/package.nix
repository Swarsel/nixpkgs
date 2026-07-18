{
  lib,
  fetchPypi,
  patatt,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "b4";
  version = "0.15.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-uBXyrtIohxjP4qFMdkIaALxPCRjqMrRd0WRcmZ/dpp0=";
  };

  propagatedBuildInputs = with python3Packages; [
    requests
    dnspython
    dkimpy
    patatt
    git-filter-repo
    textual
  ];

  # tests make dns requests and fails
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Helper utility to work with patches made available via a public-inbox archive";
    homepage = "https://git.kernel.org/pub/scm/utils/b4/b4.git/about";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      jb55
      qyliss
      mfrw
    ];

    mainProgram = "b4";
  };
})
