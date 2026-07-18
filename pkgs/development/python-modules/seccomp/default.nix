{
  lib,
  buildPythonPackage,
  cython,
  libseccomp,
}:

buildPythonPackage rec {
  pname = "libseccomp";
  version = libseccomp.version;
  src = libseccomp.pythonsrc;

  postPatch = ''
    substituteInPlace ./setup.py \
      --replace 'extra_objects=["../.libs/libseccomp.a"]' \
                'libraries=["seccomp"]'
  '';

  nativeBuildInputs = [ cython ];
  buildInputs = [ libseccomp ];
  env.VERSION_RELEASE = version; # used by build system
  doInstallCheck = true;
  format = "setuptools";
  pythonImportsCheck = [ "seccomp" ];
  unpackCmd = "tar xf $curSrc";

  meta = {
    description = "Python bindings for libseccomp";
    license = with lib.licenses; [ lgpl21 ];
    maintainers = with lib.maintainers; [ thoughtpolice ];
  };
}
