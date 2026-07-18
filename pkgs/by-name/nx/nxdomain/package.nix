{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nxdomain";
  version = "1.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "0va7nkbdjgzrf7fnbxkh1140pbc62wyj86rdrrh5wmg3phiziqkb";
  };

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  postCheck = ''
    echo example.org > simple.list
    python -m nxdomain --format dnsmasq --out dnsmasq.conf --simple ./simple.list
    grep -q 'address=/example.org/' dnsmasq.conf
  '';

  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [ dnspython ];
  pyproject = true;

  meta = {
    description = "Domain (ad) block list creator";
    homepage = "https://github.com/zopieux/nxdomain";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ zopieux ];
    platforms = lib.platforms.all;
    mainProgram = "nxdomain";
  };
})
