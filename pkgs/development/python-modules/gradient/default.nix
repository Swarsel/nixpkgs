{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  distro,
  hatch-fancy-pypi-readme,
  hatchling,
  httpx,
  pydantic,
  sniffio,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "gradient";
  version = "3.12.1";

  src = fetchFromGitHub {
    owner = "digitalocean";
    repo = "gradient-python";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4BJMUxNryePXIAG92JOX7pTbDN6FQzmYRu1+2bKEwX0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.26.3" "hatchling"
  '';

  nativeBuildInputs = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    httpx
    pydantic
    typing-extensions
    anyio
    distro
    sniffio
  ];

  pyproject = true;
  pythonImportsCheck = [ "gradient" ];

  meta = {
    description = "Python API library for Gradient";
    homepage = "https://github.com/digitalocean/gradient-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.unix;
    mainProgram = "gradient";
  };
})
