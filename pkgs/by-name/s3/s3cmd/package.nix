{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "s3cmd";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "s3tools";
    repo = "s3cmd";
    tag = "v${version}";
    sha256 = "sha256-cxwf6+9WFt3U7+JdKRgZxFElD+Dgf2P2VyejHVoiDJk=";
  };

  propagatedBuildInputs = with python3Packages; [
    python-magic
    python-dateutil
  ];

  format = "setuptools";

  meta = {
    description = "Command line tool for managing Amazon S3 and CloudFront services";
    homepage = "https://s3tools.org/s3cmd";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "s3cmd";
  };
}
