{
  lib,
  fetchFromGitHub,
  buildPecl,
}:

let
  version = "1.3.1";
in
buildPecl rec {
  inherit version;
  pname = "opentelemetry";

  src = fetchFromGitHub {
    owner = "open-telemetry";
    repo = "opentelemetry-php-instrumentation";
    rev = version;
    hash = "sha256-L58QiuwCIaNPzeh+E7/16kgUNa7vfHCowU7eDKiiImc=";
  };

  env.NIX_CFLAGS_COMPILE = "-Wno-parentheses-equality";
  doCheck = true;
  sourceRoot = "${src.name}/ext";

  meta = {
    description = "OpenTelemetry PHP auto-instrumentation extension";
    homepage = "https://opentelemetry.io/";
    changelog = "https://github.com/open-telemetry/opentelemetry-php-instrumentation/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
