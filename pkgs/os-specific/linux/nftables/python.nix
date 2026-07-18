{
  buildPythonPackage,
  nftables,
  setuptools,
}:

buildPythonPackage {
  inherit (nftables) version src;
  pname = "nftables";

  postPatch = ''
    substituteInPlace "src/nftables.py" \
      --replace-fail "libnftables.so.1" "${nftables}/lib/libnftables.so.1"
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "nftables" ];
  setSourceRoot = "sourceRoot=$(echo */py)";

  meta = {
    inherit (nftables.meta)
      description
      homepage
      license
      platforms
      maintainers
      ;
  };
}
