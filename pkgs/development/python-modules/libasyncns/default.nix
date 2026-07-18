{
  lib,
  stdenv,
  fetchurl,
  buildPythonPackage,
  libasyncns,
  pkg-config,
}:

buildPythonPackage rec {
  pname = "libasyncns-python";
  version = "0.7.1";

  src = fetchurl {
    url = "https://launchpad.net/libasyncns-python/trunk/${version}/+download/libasyncns-python-${version}.tar.bz2";
    sha256 = "1q4l71b2h9q756x4pjynp6kczr2d8c1jvbdp982hf7xzv7w5gxqg";
  };

  patches = [ ./libasyncns-fix-res-consts.patch ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace resquery.c \
      --replace '<arpa/nameser.h>' '<arpa/nameser_compat.h>'
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libasyncns ];
  doCheck = false; # requires network access
  format = "setuptools";
  pythonImportsCheck = [ "libasyncns" ];

  meta = {
    description = "Libasyncns-python is a python binding for the asynchronous name service query library";
    homepage = "https://launchpad.net/libasyncns-python";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.mic92 ];
  };
}
