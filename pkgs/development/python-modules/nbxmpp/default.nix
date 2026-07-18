{
  lib,
  fetchurl,
  fetchFromGitLab,
  buildPythonPackage,
  gobject-introspection,
  idna,
  libsoup_3,
  packaging,
  precis-i18n,
  pygobject3,
  pyopenssl,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nbxmpp";
  version = "7.2.0";

  src = fetchFromGitLab {
    owner = "gajim";
    repo = "python-nbxmpp";
    tag = version;
    hash = "sha256-OtJzCcaqcy2a46iNRcpknORgdTbzMtILocs5c6Akzrc=";
    domain = "dev.gajim.org";
  };

  nativeBuildInputs = [
    # required for pythonImportsCheck otherwise libsoup cannot be found
    gobject-introspection
    setuptools
  ];

  buildInputs = [ precis-i18n ];

  propagatedBuildInputs = [
    gobject-introspection
    idna
    libsoup_3
    packaging
    pygobject3
    pyopenssl
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "nbxmpp" ];

  meta = {
    description = "Non-blocking Jabber/XMPP module";
    homepage = "https://dev.gajim.org/gajim/python-nbxmpp";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
