{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gensim,
  numpy,
  requests,
  sentencepiece,
  setuptools,
  tqdm,
}:

buildPythonPackage {
  pname = "bpemb";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "bheinzerling";
    repo = "bpemb";
    rev = "ec85774945ca76dd93c1d9b4af2090e80c5779dc";
    hash = "sha256-nVaMXb5TBhO/vWE8AYAA3P9dSPI8O+rmzFvbEj8VEkE=";
  };

  # need network connection for tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    gensim
    numpy
    requests
    sentencepiece
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "bpemb" ];

  meta = {
    description = "Byte-pair embeddings in 275 languages";
    homepage = "https://github.com/bheinzerling/bpemb";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
