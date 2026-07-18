{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  mopidy,
  nodejs,
  npmHooks,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-iris";
  version = "3.70.0";

  src = fetchFromGitHub {
    owner = "jaedb";
    repo = "Iris";
    tag = finalAttrs.version;
    hash = "sha256-Fc0LktN8pCRnrvk9uudXu10J3XfrRbdGlcDKXFNQzmQ=";
  };

  postPatch = ''
    # turn off Google Analytics per default
    substituteInPlace src/js/store/index.js \
      --replace-fail 'allow_reporting: true' 'allow_reporting: false'
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  preBuild = ''
    npm run prod
  '';

  # no tests implemented
  doCheck = false;

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.configobj
    pythonPackages.requests
    pythonPackages.tornado
  ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-aQHq80SLaOPOANYV+aDTWC/bxfc1it5iDeRJ8L5iuEU=";
  };

  pyproject = true;
  pythonImportsCheck = [ "mopidy_iris" ];

  meta = {
    description = "Fully-functional Mopidy web client encompassing Spotify and many other backends";
    homepage = "https://github.com/jaedb/Iris";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.rvolosatovs ];
  };
})
