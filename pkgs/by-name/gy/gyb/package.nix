{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gyb";
  version = "1.95";

  src = fetchFromGitHub {
    owner = "GAM-team";
    repo = "got-your-back";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WCM+8Qvu8EF5gC5BSEbkqcyITIiHELFp1RP+Oko4MRE=";
  };

  checkPhase = ''
    runHook preCheck

    PYTHONPATH="" $out/bin/gyb --help > /dev/null

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,${python3.sitePackages}}
    mv gyb.py $out/bin/gyb
    mv *.py $out/${python3.sitePackages}/

    runHook postInstall
  '';

  dependencies = with python3.pkgs; [
    google-api-python-client
    google-auth
    google-auth-oauthlib
    google-auth-httplib2
    httplib2
  ];

  pyproject = false;

  meta = {
    description = ''
      Got Your Back (GYB) is a command line tool for backing up your Gmail
      messages to your computer using Gmail's API over HTTPS.
    '';

    homepage = "https://github.com/GAM-team/got-your-back";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ austinbutler ];
    mainProgram = "gyb";
  };
})
