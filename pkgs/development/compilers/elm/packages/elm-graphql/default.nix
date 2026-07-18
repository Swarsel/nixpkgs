{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  elmPackages,
}:

buildNpmPackage (finalAttrs: {
  pname = "elm-graphql";
  version = "4.3.2-beta.0";

  src = fetchFromGitHub {
    owner = "dillonkearns";
    repo = "elm-graphql";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wfp21QINwj93490XmdH1LUg8LSi44EupuDH+61srZL8=";
  };

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "elm-tooling install" "true"
  '';

  nativeBuildInputs = [
    elmPackages.elm
  ];

  npmDepsHash = "sha256-Fx0ylqXHdu48mZSMtedyLyb4+Ssn4DrQ34pTJAy2x7c=";

  postConfigure = (
    elmPackages.fetchElmDeps {
      elmPackages = import ./elm-srcs.nix;
      elmVersion = elmPackages.elm.version;
      registryDat = ./registry.dat;
    }
  );

  npmFlags = [ "--ignore-scripts" ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Autogenerate type-safe GraphQL queries in Elm";
    homepage = "https://github.com/dillonkearns/elm-graphql";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "elm-graphql";
  };
})
