{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dask,
  fastparquet,
  pandas,
  pyarrow,
  setuptools,
  versioneer,
}:

buildPythonPackage rec {
  pname = "intake-parquet";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "intake";
    repo = "intake-parquet";
    tag = version;
    hash = "sha256-zSwylXBKOM/tG5mwYtc0FmxwcKJ6j+lw1bxJqf57NY8=";
  };

  postPatch = ''
    # Remove vendorized versioneer.py
    rm versioneer.py
  '';

  doCheck = false;

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    pandas
    dask
    fastparquet
    pyarrow
  ];

  pyproject = true;
  # Break circular dependency
  pythonRemoveDeps = [ "intake" ];

  #pythonImportsCheck = [ "intake_parquet" ];
  meta = {
    description = "Parquet plugin for Intake";
    homepage = "https://github.com/intake/intake-parquet";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
