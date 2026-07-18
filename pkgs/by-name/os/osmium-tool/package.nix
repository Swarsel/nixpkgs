{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  bzip2,
  cmake,
  expat,
  installShellFiles,
  libosmium,
  lz4,
  nlohmann_json,
  pandoc,
  protozero,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osmium-tool";
  version = "1.19.1";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmium-tool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WPNXzS5XiCWSA5iycPqulybQtVED9oVfAsRz0WYmApA=";
  };

  nativeBuildInputs = [
    cmake
    installShellFiles
    pandoc
  ];

  buildInputs = [
    boost
    bzip2
    expat
    libosmium
    lz4
    nlohmann_json
    protozero
    zlib
  ];

  doCheck = true;

  preCheck = ''
    export OSMIUM_PAGER=cat
  '';

  postInstall = ''
    installShellCompletion --zsh ../zsh_completion/_osmium
  '';

  meta = {
    description = "Multipurpose command line tool for working with OpenStreetMap data based on the Osmium library";
    homepage = "https://osmcode.org/osmium-tool/";
    changelog = "https://github.com/osmcode/osmium-tool/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      gpl3Plus
      mit
      bsd3
    ];

    maintainers = with lib.maintainers; [ das-g ];
    mainProgram = "osmium";
    teams = [ lib.teams.geospatial ];
  };
})
