{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  isPy3k,
  openssl,
}:

buildPythonPackage rec {
  pname = "python-bitcoinlib";
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "petertodd";
    repo = "python-bitcoinlib";
    tag = "python-bitcoinlib-v${version}";
    hash = "sha256-jfd2Buy6GSCH0ZeccRREC1NmlS6Mq1qtNv/NLNJOsX0=";
  };

  postPatch = ''
    substituteInPlace bitcoin/core/key.py --replace \
      "ctypes.util.find_library('ssl.35') or ctypes.util.find_library('ssl') or ctypes.util.find_library('libeay32')" \
      "'${lib.getLib openssl}/lib/libssl${stdenv.hostPlatform.extensions.sharedLibrary}'"
  '';

  disabled = !isPy3k;
  format = "setuptools";

  pythonImportsCheck = [
    "bitcoin"
    "bitcoin.core.key"
  ];

  meta = {
    description = "Easy interface to the Bitcoin data structures and protocol";
    homepage = "https://github.com/petertodd/python-bitcoinlib";
    changelog = "https://github.com/petertodd/python-bitcoinlib/raw/${src.rev}/release-notes.md";
    license = with lib.licenses; [ lgpl3Plus ];
    maintainers = with lib.maintainers; [ jb55 ];
  };
}
