{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "pa-ringbuffer";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "spatialaudio";
    repo = "python-pa-ringbuffer";
    rev = version;
    sha256 = "1d4k6z13mc1f88m6wbhfx8hillb7q78n33ws5bmyblsdkv1gx607";
  };

  format = "setuptools";

  meta = {
    description = "Adds ring buffer functionality";
    homepage = "https://github.com/spatialaudio/python-pa-ringbuffer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ laikq ];
  };
}
