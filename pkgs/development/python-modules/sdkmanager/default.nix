{
  lib,
  fetchFromGitLab,
  argcomplete,
  buildPythonPackage,
  gnupg,
  looseversion,
  pythonAtLeast,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sdkmanager";
  version = "0.7.0";

  src = fetchFromGitLab {
    owner = "fdroid";
    repo = "sdkmanager";
    tag = version;
    hash = "sha256-/MrRCR6TJ64DiL4D1290jik1L+jITi4dH9Tj3cjF+ms=";
  };

  # has no tests
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/sdkmanager \
      --suffix PATH : ${lib.makeBinPath [ gnupg ]}
  '';

  build-system = [ setuptools ];

  dependencies = [
    argcomplete
    requests
  ]
  ++ requests.optional-dependencies.socks
  ++ lib.optionals (pythonAtLeast "3.12") [ looseversion ];

  pyproject = true;
  pythonImportsCheck = [ "sdkmanager" ];
  pythonRelaxDeps = [ "urllib3" ];

  meta = {
    description = "Drop-in replacement for sdkmanager from the Android SDK written in Python";
    homepage = "https://gitlab.com/fdroid/sdkmanager";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ linsui ];
    mainProgram = "sdkmanager";
  };
}
