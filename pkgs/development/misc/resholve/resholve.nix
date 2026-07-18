{
  lib,
  binlore,
  callPackage,
  gawk,
  installShellFiles,
  rSrc,
  resholve,
  resholve-utils,
  version,
}:
let
  python27 = callPackage ./python27.nix { };
in
python27.pkgs.buildPythonApplication {
  inherit version;
  pname = "resholve";
  src = rSrc;

  postPatch = ''
    for file in setup.cfg _resholve/version.py; do
      substituteInPlace $file --subst-var-by version ${version}
    done
  '';

  nativeBuildInputs = [ installShellFiles ];

  propagatedBuildInputs = with python27.pkgs; [
    oildev
    configargparse
    sedparse
  ];

  postInstall = ''
    installManPage resholve.1
  '';

  # Do not propagate Python; may be obsoleted by nixos/nixpkgs#102613
  # for context on why, see abathur/resholve#20
  postFixup = ''
    rm $out/nix-support/propagated-build-inputs
  '';

  __structuredAttrs = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ gawk ])
  ];

  passthru = {
    inherit (resholve-utils)
      mkDerivation
      phraseSolution
      writeScript
      writeScriptBin
      ;

    tests = callPackage ./test.nix {
      inherit
        rSrc
        binlore
        resholve
        ;
    };
  };

  meta = {
    description = "Resolve external shell-script dependencies";
    homepage = "https://github.com/abathur/resholve";
    changelog = "https://github.com/abathur/resholve/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ abathur ];
    platforms = lib.platforms.all;

    knownVulnerabilities = [
      ''
        resholve depends on python27 (EOL). While it's safe to
        run on trusted input in the build sandbox, you should
        avoid running it on untrusted input.
      ''
    ];
  };
}
