{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "altdns";
  version = "1.0.2-unstable-2021-09-09";

  src = fetchFromGitHub {
    owner = "infosec-au";
    repo = "altdns";
    rev = "8c1de0fa8365153832bb58d74475caa15d2d077a";
    hash = "sha256-ElY6AZ7IBnOh7sRWNSQNmq7AYGlnjvYRn8/U+29BwWA=";
  };

  # Project has no tests
  doCheck = false;

  postInstall = ''
    cp $src/words.txt $out/
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    dnspython
    termcolor
    tldextract
  ];

  pyproject = true;

  pythonImportsCheck = [
    "altdns"
  ];

  pythonRemoveDeps = [ "argparse" ];

  meta = {
    description = "Generates permutations, alterations and mutations of subdomains and then resolves them";
    homepage = "https://github.com/infosec-au/altdns";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ octodi ];
    mainProgram = "altdns";
  };
}
