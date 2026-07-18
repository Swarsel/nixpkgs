{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  filelock,
  packaging,
  requests,
  setuptools,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "modelscope";
  version = "1.37.1";

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "modelscope";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LNg2JtqqID6RKuFi+j29NfOWuNZhkkTIdKmL9bXzAvs=";
  };

  doCheck = false; # need network
  build-system = [ setuptools ];

  dependencies = [
    filelock
    packaging
    requests
    setuptools
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "modelscope" ];

  meta = {
    description = "Bring the notion of Model-as-a-Service to life";
    homepage = "https://github.com/modelscope/modelscope";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kyehn
      doronbehar
      ryan4yin
    ];

    mainProgram = "modelscope";
  };
})
