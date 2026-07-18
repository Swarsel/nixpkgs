{
  lib,
  buildPythonPackage,
  fastcore,
  fastdownload,
  fastprogress,
  fetchPypi,
  matplotlib,
  pandas,
  pillow,
  requests,
  scikit-learn,
  scipy,
  spacy,
  torchvision,
}:

buildPythonPackage rec {
  pname = "fastai";
  version = "2.8.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eZW96Upogr6qws6lD8eX2kywuBmTXsbG7vaQKLwx9y8=";
  };

  propagatedBuildInputs = [
    fastprogress
    fastcore
    fastdownload
    torchvision
    matplotlib
    pillow
    scikit-learn
    scipy
    spacy
    pandas
    requests
  ];

  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "fastai" ];

  meta = {
    description = "Fastai deep learning library";
    homepage = "https://github.com/fastai/fastai";
    changelog = "https://github.com/fastai/fastai/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rxiao ];
    mainProgram = "configure_accelerate";
  };
}
