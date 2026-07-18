{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
  lightyear,
}:
build-idris-package {
  pname = "yaml";
  version = "2018-01-25";

  src = fetchFromGitHub {
    owner = "Heather";
    repo = "Idris.Yaml";
    rev = "5afa51ffc839844862b8316faba3bafa15656db4";
    sha256 = "1g4pi0swmg214kndj85hj50ccmckni7piprsxfdzdfhg87s0avw7";
  };

  idrisDeps = [
    contrib
    lightyear
  ];

  ipkgName = "Yaml";

  meta = {
    description = "Idris YAML lib";
    homepage = "https://github.com/Heather/Idris.Yaml";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
