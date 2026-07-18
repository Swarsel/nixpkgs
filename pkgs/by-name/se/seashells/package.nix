{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "seashells";
  version = "0.1.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-RBs28FC7f82DrxRcmvTP9nljVpm7tjrGuvr05l32hDM=";
  };

  doCheck = false; # there are no tests
  build-system = with python3Packages; [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "seashells" ];

  meta = {
    description = "Pipe command-line programs to seashells.io";

    longDescription = ''
      Official cient for seashells.io, which allows you to view
      command-line output on the web, in real-time.
    '';

    homepage = "https://seashells.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ deejayem ];
    mainProgram = "seashells";
  };
})
