{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  filetype,
  mutagen,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mediafile";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "beetbox";
    repo = "mediafile";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FujuFkZH0wjZcd3wIpJw8mDvE/2/mew5tfxAyxA2RkI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    filetype
    mutagen
  ];

  pyproject = true;
  pythonImportsCheck = [ "mediafile" ];

  meta = {
    description = "Python interface to the metadata tags for many audio file formats";
    homepage = "https://github.com/beetbox/mediafile";
    changelog = "https://github.com/beetbox/mediafile/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lovesegfault ];
  };
})
