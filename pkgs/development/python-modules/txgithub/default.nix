{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyopenssl,
  service-identity,
  twisted,
}:

buildPythonPackage rec {
  pname = "txgithub";
  version = "15.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "16gbizy8vkxasxylwzj4p66yw8979nvzxdj6csidgmng7gi2k8nx";
  };

  propagatedBuildInputs = [
    pyopenssl
    twisted
    service-identity
  ];

  # No tests distributed
  doCheck = false;
  format = "setuptools";

  # fix python3 issues
  patchPhase = ''
    sed -i 's/except usage.UsageError, errortext/except usage.UsageError as errortext/' txgithub/scripts/create_token.py
    sed -i 's/except usage.UsageError, errortext/except usage.UsageError as errortext/' txgithub/scripts/gist.py
    sed -i 's/print response\[\x27html_url\x27\]/print(response\[\x27html_url\x27\])/' txgithub/scripts/gist.py
    sed -i '41d' txgithub/scripts/gist.py
    sed -i '41d' txgithub/scripts/gist.py
  '';

  meta = {
    description = "GitHub API client implemented using Twisted";
    homepage = "https://github.com/tomprince/txgithub";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
