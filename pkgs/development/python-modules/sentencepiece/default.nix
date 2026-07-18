{
  buildPythonPackage,
  pkg-config,
  sentencepiece,
}:

buildPythonPackage rec {
  inherit (sentencepiece) version src;
  pname = "sentencepiece";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sentencepiece.dev ];
  format = "setuptools";
  pythonImportsCheck = [ "sentencepiece" ];
  sourceRoot = "${src.name}/python";
  # sentencepiece installs 'bin' output.
  meta = removeAttrs sentencepiece.meta [ "outputsToInstall" ];
}
