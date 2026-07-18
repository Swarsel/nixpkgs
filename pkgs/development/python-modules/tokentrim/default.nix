{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  tiktoken,
}:

buildPythonPackage rec {
  pname = "tokentrim";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "KillianLucas";
    repo = "tokentrim";
    tag = "v${version}";
    hash = "sha256-zr2SLT3MBuMD98g9fdS0mLuijcssRQ/S3+tCq2Cw1/4=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ tiktoken ];
  # tests connect to openai
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "tokentrim" ];

  meta = {
    description = "Easily trim 'messages' arrays for use with GPTs";
    homepage = "https://github.com/KillianLucas/tokentrim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
