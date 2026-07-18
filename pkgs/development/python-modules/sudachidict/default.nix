{
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  sudachidict,
  sudachipy,
}:

buildPythonPackage rec {
  inherit (sudachidict) version meta;
  pname = "sudachidict-${sudachidict.dict-type}";

  src = fetchFromGitHub {
    owner = "WorksApplications";
    repo = "SudachiDict";
    tag = "v${version}";
    hash = "sha256-2YI/9y222/mbzDi/3GgwPjAdwnH8qw7viuaQnrVqsZA=";
  };

  # setup script tries to get data from the network but we use the nixpkgs' one
  postPatch = ''
    substituteInPlace setup.py \
      --replace 'ZIP_NAME = urlparse(ZIP_URL).path.split("/")[-1]' "" \
      --replace "not os.path.exists(RESOURCE_DIR)" "False"
    substituteInPlace INFO.json \
      --replace "%%VERSION%%" ${version} \
      --replace "%%DICT_VERSION%%" ${version} \
      --replace "%%DICT_TYPE%%" ${sudachidict.dict-type}
  '';

  # we need to prepare some files before the build
  # https://github.com/WorksApplications/SudachiDict/blob/develop/package_python.sh
  preBuild = ''
    install -Dm644 ${sudachidict}/share/system.dic -t sudachidict_${sudachidict.dict-type}/resources
    touch sudachidict_${sudachidict.dict-type}/__init__.py
  '';

  build-system = [ setuptools ];
  dependencies = [ sudachipy ];
  pyproject = true;
  sourceRoot = "${src.name}/python";
}
