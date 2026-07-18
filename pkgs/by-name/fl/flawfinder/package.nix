{
  lib,
  fetchurl,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "flawfinder";
  version = "2.0.20";

  src = fetchurl {
    url = "https://dwheeler.com/flawfinder/flawfinder-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-nXMqTg/vHNTq7v1KAJPxg8WYH2yENxHOrmpjQZQEmWs=";
  };

  # Project is using a combination of bash/Python for the tests
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "flawfinder" ];

  meta = {
    description = "Tool to examines C/C++ source code for security flaws";
    homepage = "https://dwheeler.com/flawfinder/";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.all;
    mainProgram = "flawfinder";
  };
})
