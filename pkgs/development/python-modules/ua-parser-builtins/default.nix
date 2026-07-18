{
  buildPythonPackage,
  hatchling,
  pyyaml,
  ua-parser,
  versioningit,
}:

buildPythonPackage rec {
  inherit (ua-parser) version src;
  pname = "ua-parser-builtins";

  postPatch = ''
    # don't use git to determine version
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    hatchling
    pyyaml
    versioningit
  ];

  pyproject = true;
  sourceRoot = "${src.name}/ua-parser-builtins";

  meta = {
    inherit (ua-parser.meta)
      description
      homepage
      license
      changelog
      ;

    maintainers = [ ];
  };
}
