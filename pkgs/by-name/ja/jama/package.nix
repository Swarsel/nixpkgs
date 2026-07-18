{
  lib,
  stdenv,
  fetchurl,
  tnt,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "jama";
  version = "1.2.5";

  src = fetchurl {
    url = "https://math.nist.gov/tnt/jama125.zip";
    sha256 = "031ns526fvi2nv7jzzv02i7i5sjcyr0gj884i3an67qhsx8vyckl";
  };

  nativeBuildInputs = [ unzip ];
  propagatedBuildInputs = [ tnt ];

  installPhase = ''
    mkdir -p $out/include
    cp *.h $out/include
  '';

  unpackPhase = ''
    mkdir "${pname}-${version}"
    unzip "$src"
  '';

  meta = {
    description = "JAMA/C++ Linear Algebra Package: Java-like matrix C++ templates";
    homepage = "https://math.nist.gov/tnt/";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.unix;
  };
}
