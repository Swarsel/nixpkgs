{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "zhong-hong-hvac";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "crhan";
    repo = "ZhongHongHVAC";
    tag = "v${version}";
    hash = "sha256-WLSmzvRydfYhLBZZW4EZDCFXZYqowA6vS0GJUl2UadQ=";
  };

  # Tests require network hardware connection
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ attrs ];
  pyproject = true;
  pythonImportsCheck = [ "zhong_hong_hvac" ];

  meta = {
    description = "Python library for interfacing with ZhongHong HVAC controller";
    homepage = "https://github.com/crhan/ZhongHongHVAC";
    changelog = "https://github.com/crhan/ZhongHongHVAC/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
