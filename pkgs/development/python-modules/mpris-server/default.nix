{
  lib,
  buildPythonPackage,
  emoji,
  fetchPypi,
  pydbus,
  pygobject3,
  setuptools,
  strenum,
  unidecode,
}:
buildPythonPackage (finalAttrs: {
  pname = "mpris-server";
  version = "0.9.6";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-T0ZeDQiYIAhKR8aw3iv3rtwzc+R0PTQuIh6+Hi4rIHQ=";
    pname = "mpris_server";
  };

  postPatch = ''
    substituteInPlace mpris_server/__init__.py \
      --replace-fail \
        "__version__: Final[str] = '0.9.0'" \
        "__version__: Final[str] = '${finalAttrs.version}'"
  '';

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    emoji
    pydbus
    pygobject3
    strenum
    unidecode
  ];

  pyproject = true;
  pythonImportsCheck = [ "mpris_server" ];

  meta = {
    description = "Publish a MediaPlayer2 MPRIS device to D-Bus";
    homepage = "https://pypi.org/project/mpris-server/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ pbsds ];
  };
})
