{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dask,
  ipywidgets,
  pandas,
  psutil,
  ray,
  setuptools,
  tqdm,
}:

buildPythonPackage rec {
  pname = "swifter";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "jmcarpenter2";
    repo = "swifter";
    tag = version;
    hash = "sha256-lgdf8E9GGjeLY4ERzxqtjQuYVtdtIZt2HFLSiNBbtX4=";
  };

  # tests may hang due to ignoring cpu core limit
  # https://github.com/jmcarpenter2/swifter/issues/221
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pandas
    psutil
    dask
    tqdm
  ]
  ++ dask.optional-dependencies.dataframe;

  optional-dependencies = {
    groupby = [ ray ];
    notebook = [ ipywidgets ];
  };

  pyproject = true;
  pythonImportsCheck = [ "swifter" ];

  meta = {
    description = "Package which efficiently applies any function to a pandas dataframe or series in the fastest available manner";
    homepage = "https://github.com/jmcarpenter2/swifter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
