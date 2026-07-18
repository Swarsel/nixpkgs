{
  lib,
  buildPythonPackage,
  fetchPypi,
  lilypond,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "jianpu-ly";
  version = "1.870";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-1jhMoHqEkkuSrWzJ3yu/iPA9l29c0xTYN1/Mqaf8TdM=";
    pname = "jianpu_ly";
  };

  # no tests in shipped with upstream
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ lilypond ];
  pyproject = true;
  pythonImportsCheck = [ "jianpu_ly" ];

  meta = {
    description = "Assists with printing jianpu";
    homepage = "https://ssb22.user.srcf.net/mwrhome/jianpu-ly.html";
    changelog = "https://github.com/ssb22/jianpu-ly/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ifurther ];
  };
})
