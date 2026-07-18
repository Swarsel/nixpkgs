{
  lib,
  buildPackages,
  buildPythonPackage,
  fetchPypi,
  pkg-config,
  pytest,
  zstd,
}:

buildPythonPackage rec {
  pname = "zstd";
  version = "1.5.7.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QD5SBfSsBLkuawzaZUvi9R3iaCKKDbAGe8CH+qzy9JU=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "/usr/bin/pkg-config" "${buildPackages.pkg-config}/bin/${buildPackages.pkg-config.targetPrefix}pkg-config"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zstd ];

  env = {
    PKG_VERSION = version;
    VERSION = zstd.version;
    # Running tests via setup.py triggers an attempt to recompile with the vendored zstd
    ZSTD_EXTERNAL = 1;
  };

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    pytest
  '';

  format = "setuptools";

  setupPyBuildFlags = [
    "--external"
    "--include-dirs=${zstd}/include"
    "--libraries=zstd"
    "--library-dirs=${zstd}/lib"
  ];

  meta = {
    description = "Simple python bindings to Yann Collet ZSTD compression library";
    homepage = "https://github.com/sergey-dryabzhinsky/python-zstd";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ eadwu ];
  };
}
