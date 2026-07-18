{
  lib,
  buildPythonPackage,
  bwa,
  cffi,
  fetchPypi,
  pythonAtLeast,
  zlib,
}:

buildPythonPackage rec {
  pname = "bwapy";
  version = "0.1.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "090qwx3vl729zn3a7sksbviyg04kc71gpbm3nd8dalqp673x1npw";
  };

  postPatch = ''
    # replace bundled bwa
    rm -r bwa/*
    cp ${bwa}/lib/*.a ${bwa}/include/*.h bwa/

    substituteInPlace setup.py \
      --replace 'setuptools>=49.2.0' 'setuptools'
  '';

  buildInputs = [
    zlib
    bwa
  ];

  propagatedBuildInputs = [ cffi ];
  # no tests
  doCheck = false;
  # uses the removed imp module
  disabled = pythonAtLeast "3.12";
  format = "setuptools";
  pythonImportsCheck = [ "bwapy" ];

  meta = {
    description = "Python bindings to bwa mem aligner";
    homepage = "https://github.com/ACEnglish/bwapy";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ris ];
    mainProgram = "bwamempy";
  };
}
