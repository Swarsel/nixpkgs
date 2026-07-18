{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  result,
  seq,
}:

buildDunePackage rec {
  pname = "tiny_httpd";
  version = "0.16";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-9L4WCduQNj5Jd/u3SozuXiGTkgojwfGIP5KgQmnWgQw=";
  };

  buildInputs = [ result ];
  propagatedBuildInputs = [ seq ];
  minimalOCamlVersion = "4.08";

  meta = {
    inherit (src.meta) homepage;
    description = "Minimal HTTP server using good old threads";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "http_of_dir";
  };
}
