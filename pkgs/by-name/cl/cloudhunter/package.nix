{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cloudhunter";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "belane";
    repo = "CloudHunter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7iT4vr0kcNXEyJJdBbJsllIcbZRGY3T5t/FjEONkuq0=";
  };

  postPatch = ''
    substituteInPlace cloudhunter.py \
      --replace "'permutations.txt'" "'$out/share/permutations.txt'" \
      --replace "'resolvers.txt'" "'$out/share/resolvers.txt'"
  '';

  propagatedBuildInputs = with python3.pkgs; [
    beautifulsoup4
    dnspython
    requests
    tldextract
    urllib3
    xmltodict
  ];

  # Project has no tests
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -vD cloudhunter.py $out/bin/cloudhunter
    install -vD  permutations-big.txt permutations.txt resolvers.txt -t $out/share
    install -vd $out/${python3.sitePackages}/
    runHook postInstall
  '';

  pyproject = false;

  meta = {
    description = "Cloud bucket scanner";
    homepage = "https://github.com/belane/CloudHunter";
    changelog = "https://github.com/belane/CloudHunter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "cloudhunter";
  };
})
