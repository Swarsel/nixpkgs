{
  lib,
  fetchFromGitHub,
  berkeleydb,
  buildPythonPackage,
  libmilter,
  py3dns,
  pyasyncore,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymilter";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "sdgathman";
    repo = "pymilter";
    tag = "pymilter-${version}";
    hash = "sha256-plaWXwDAIsVzEtrabZuZj7T4WNfz2ntQHgcMCVf5S70=";
  };

  buildInputs = [ libmilter ];

  preBuild = ''
    substituteInPlace Milter/greylist.py \
      --replace-fail "import thread" "import _thread as thread"
  '';

  nativeCheckInputs = [
    pyasyncore
  ];

  # testpolicy: requires makemap (#100419)
  #   using exec -a makemap smtpctl results in "unknown group smtpq"
  preCheck = ''
    sed -i '/testpolicy/d' test.py
    rm testpolicy.py
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    berkeleydb
    py3dns
  ];

  pyproject = true;
  pythonImportsCheck = [ "Milter" ];

  meta = {
    description = "Python bindings for libmilter api";
    homepage = "http://bmsi.com/python/milter.html";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ yorickvp ];
  };
}
