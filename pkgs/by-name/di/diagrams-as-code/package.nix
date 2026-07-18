{
  lib,
  fetchFromGitHub,
  diagrams-as-code,
  python3Packages,
  runCommand,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "diagrams-as-code";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "dmytrostriletskyi";
    repo = "diagrams-as-code";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cd602eQvNCUQuCdn/RpcfURcDHjXLZ0gAG+SObB++Q0=";
  };

  doCheck = false; # no tests
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    diagrams
    pydantic
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "diagrams_as_code" ];

  pythonRelaxDeps = [
    "diagrams"
    "pydantic"
    "pyyaml"
  ];

  passthru.tests = {
    simple = runCommand "diagrams-as-code-test" { } ''
      # giving full path to diagrams-as-code causes
      # a bad path concatenation
      cp ${diagrams-as-code.src}/examples/all-fields.yaml .

      ${lib.getExe diagrams-as-code} all-fields.yaml

      cp web-services-architecture-aws.jpg $out
    '';
  };

  meta = {
    description = "Declarative configurations using YAML for drawing cloud system architectures";
    homepage = "https://github.com/dmytrostriletskyi/diagrams-as-code";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "diagrams-as-code";
  };
})
