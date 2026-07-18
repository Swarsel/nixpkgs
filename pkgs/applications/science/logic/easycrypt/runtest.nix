{ easycrypt, python3Packages }:

python3Packages.buildPythonApplication {
  inherit (easycrypt) src version;
  pname = "easycrypt-runtest";
  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp scripts/testing/runtest $out/bin/ec-runtest
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  pyproject = false;
  pythonPath = with python3Packages; [ pyyaml ];

  meta = easycrypt.meta // {
    description = "Testing program for EasyCrypt formalizations";
    mainProgram = "ec-runtest";
  };
}
