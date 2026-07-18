{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pinentry-curses,
  setuptools,
}:

buildPythonPackage {
  pname = "pynentry";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "Laharah";
    repo = "pynentry";
    rev = "54a484b36b8ac16c0ae51fe436844d5a056ec3c9";
    hash = "sha256-bbuAI0IB3cTIfaCCrq0g93geRLUsxaahHWuU3bBtHII";
  };

  postPatch = ''
    substituteInPlace pynentry.py \
      --replace-fail 'executable="pinentry"' 'executable="${lib.getExe pinentry-curses}"'
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pynentry" ];

  meta = {
    description = "Wrapper for pinentry for python";
    homepage = "https://github.com/Laharah/pynentry";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ lilahummel ];
  };
}
