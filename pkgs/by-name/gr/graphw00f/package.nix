{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "graphw00f";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "dolevf";
    repo = "graphw00f";
    tag = version;
    hash = "sha256-8fOvcc//UdDawgGMAhbYQ/O5kd1l2skWGDlFNYocNY8=";
  };

  installPhase = ''
    runHook preInstall

    install -vD main.py $out/bin/graphw00f
    install -vD {conf,version}.py -t $out/${python3.sitePackages}/
    install -vD graphw00f/* -t $out/${python3.sitePackages}/graphw00f

    runHook postInstall
  '';

  dependencies = with python3.pkgs; [ requests ];
  pyproject = false;

  meta = {
    description = "GraphQL Server Engine Fingerprinting utility";
    homepage = "https://github.com/dolevf/graphw00f";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "graphw00f";
  };
}
