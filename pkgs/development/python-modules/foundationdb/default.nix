{
  lib,
  buildPythonPackage,
  foundationdb,
}:

buildPythonPackage {
  pname = "foundationdb";
  version = foundationdb.version;
  src = foundationdb.pythonsrc;
  doCheck = false;
  format = "setuptools";

  patchPhase = ''
    substituteInPlace ./fdb/impl.py \
      --replace libfdb_c.so "${foundationdb.lib}/lib/libfdb_c.so"
  '';

  unpackCmd = "tar xf $curSrc";

  meta = {
    description = "Python bindings for FoundationDB";
    homepage = "https://www.foundationdb.org";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ thoughtpolice ];
  };
}
