{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  gauge-unwrapped,
  nodejs,
  unzip,
}:
buildNpmPackage rec {
  pname = "gauge-plugin-js";
  version = "5.0.6";

  src = fetchFromGitHub {
    owner = "getgauge";
    repo = "gauge-js";
    rev = "v${version}";
    hash = "sha256-/hfsBoZ37A4W3uejmOnl6nZv0oCedkQFMNidqWb9DN8=";
    fetchSubmodules = true;
  };

  postPatch = ''
    patchShebangs index.js
  '';

  nativeBuildInputs = [ unzip ];
  buildInputs = [ nodejs ];
  npmDepsHash = "sha256-2kZDpRUegHqZOEc49h3+RRAbKroW7v63bXjzDAu/bCc=";

  installPhase = ''
    mkdir -p $out/share/gauge-plugins/js/${version}
    unzip deploy/gauge-js-${version}.zip -d $out/share/gauge-plugins/js/${version}
  '';

  npmBuildScript = "package";

  meta = {
    inherit (gauge-unwrapped.meta) platforms;
    description = "Gauge plugin that lets you write tests in JavaScript";
    homepage = "https://github.com/getgauge/gauge-js/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
