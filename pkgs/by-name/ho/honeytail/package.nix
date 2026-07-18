{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "honeytail";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "honeycombio";
    repo = "honeytail";
    rev = "v${finalAttrs.version}";
    hash = "sha256-S0hIgNNzF1eNe+XJs+PT7EUIl5oJCXu+B/zQago4sf8=";
  };

  vendorHash = "sha256-LtiiLGLjhbfT49A6Fw5CbSbnmTHMxtcUssr+ayCVrvY=";

  meta = {
    description = "Agent for ingesting log file data into honeycomb.io and making it available for exploration";
    homepage = "https://honeycomb.io/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.iand675 ];
  };
})
