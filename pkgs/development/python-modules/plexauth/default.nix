{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "plexauth";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "jjlawren";
    repo = "python-plexauth";
    rev = "v${version}";
    sha256 = "1wy6syz3cgfw28zvigh2br4jabg8rzpi5l0bhfb6vjjc7aam13ag";
  };

  propagatedBuildInputs = [ aiohttp ];
  # package does not include tests
  doCheck = false;
  format = "setuptools";
  # at least guarantee the module can be imported
  pythonImportsCheck = [ "plexauth" ];

  meta = {
    description = "Handles the authorization flow to obtain tokens from Plex.tv via external redirection";
    homepage = "https://github.com/jjlawren/python-plexauth/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
