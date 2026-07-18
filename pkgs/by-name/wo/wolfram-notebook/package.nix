{
  stdenv,
  jupyter,
  wolfram-for-jupyter-kernel,
  writeScriptBin,
}:

let
  wolfram-jupyter = jupyter.override {
    definitions = {
      wolfram = wolfram-for-jupyter-kernel.definition;
    };
  };
in
writeScriptBin "wolfram-notebook" ''
  #! ${stdenv.shell}
  ${wolfram-jupyter}/bin/jupyter-notebook
''
