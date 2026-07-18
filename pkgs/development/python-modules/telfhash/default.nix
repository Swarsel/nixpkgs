{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  capstone,
  packaging,
  pyelftools,
  setuptools,
  tlsh,
}:
buildPythonPackage rec {
  pname = "telfhash";
  version = "0.9.8";

  src = fetchFromGitHub {
    owner = "trendmicro";
    repo = "telfhash";
    rev = "v${version}";
    sha256 = "124zajv43wx9l8rvdvmzcnbh0xpzmbn253pznpbjwvygfx16gq02";
  };

  # The tlsh library's name is just "tlsh"
  postPatch = ''
    substituteInPlace requirements.txt \
       --replace-fail "python-tlsh" "tlsh" \
       --replace-fail "py-tlsh" "tlsh" \
       --replace-fail "nose>=1.3.7" ""
  '';

  doCheck = false; # no tests
  build-system = [ setuptools ];

  dependencies = [
    capstone
    pyelftools
    tlsh
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "telfhash" ];

  meta = {
    description = "Symbol hash for ELF files";
    homepage = "https://github.com/trendmicro/telfhash";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "telfhash";
  };
}
