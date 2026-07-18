{
  lib,
  stdenv,
  ethtool,
  fetchFromCodeberg,
  iproute2,
  libbpf,
  nixosTests,
  python3Packages,
  yq,
  withBpf ? false,
  withConfigValidation ? true,
  withShellColor ? false,
}:

let
  version = "2.4.1";
  src = fetchFromCodeberg {
    owner = "routerkit";
    repo = "ifstate";
    tag = version;
    hash = "sha256-/kibcWSGg7AqkjvQAzhSs+aoRHE/YoYhTqVjw4NWNgA=";
  };
  docs = stdenv.mkDerivation {
    inherit version src;
    pname = "ifstate-docs";

    postPatch = ''
      # git-revision-date requires a git repository
      # privacy and social plugin require internet
      yq -yi 'del(.plugins[] | select((type == "object" and (has("git-revision-date-localized") or has("social"))) or (type == "string" and . == "privacy")))' mkdocs.yaml
    '';

    nativeBuildInputs = [ yq ];

    buildInputs =
      with python3Packages;
      (
        [
          mkdocs-material
          mike
          mkdocs-glightbox
          mkdocs-macros-plugin
          mkdocs-minify-plugin
        ]
        ++ mkdocs-material.optional-dependencies.imaging
      );

    buildPhase = ''
      runHook preBuild
      mkdir -p $out
      mkdocs build -d $out
      runHook postBuild
    '';
  };
  self = python3Packages.buildPythonApplication rec {
    inherit version src;
    pname = "ifstate";

    postPatch = ''
      substituteInPlace libifstate/routing/__init__.py \
        --replace-fail '/usr/share/iproute2' '${iproute2}/share/iproute2'

      substituteInPlace libifstate/link/base.py \
        --replace-fail "/usr/sbin/ethtool" "${lib.getExe ethtool}"
    ''
    + lib.optionalString withBpf ''
      substituteInPlace libifstate/bpf/ctypes.py \
        --replace-fail 'libbpf.so.1' '${libbpf}/lib/libbpf.so.1'
    '';

    # has no unit tests
    doCheck = false;

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies =
      with python3Packages;
      [
        pyroute2
        pyyaml
        setproctitle
      ]
      ++ lib.optional withConfigValidation jsonschema
      ++ lib.optional withShellColor pygments;

    pyproject = true;

    pythonImportsCheck = [
      "libifstate"
      "ifstate"
    ];

    pythonRemoveDeps = lib.optional (!withConfigValidation) "jsonschema";

    passthru = {
      inherit docs;

      features = {
        inherit
          withBpf
          withConfigValidation
          withShellColor
          ;
      };

      # needed for access in schema validaten in module
      jsonschema = "${self}/${python3Packages.python.sitePackages}/libifstate/schema/2/ifstate.conf.schema.json";
      tests = nixosTests.ifstate;
    };

    meta = {
      description = "Manage host interface settings in a declarative manner";
      homepage = "https://ifstate.net";
      changelog = "https://codeberg.org/liske/ifstate/src/tag/${src.tag}/CHANGELOG.md";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [ marcel ];
      platforms = lib.platforms.linux;
      mainProgram = "ifstatecli";
    };
  };
in
self
