{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "matcha-rss-digest";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "piqoni";
    repo = "matcha";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ezwZmJVJjbrrWJAsZ3+CUZ7K4WpA1HLKL9V+kTZTfj8=";
  };

  vendorHash = "sha256-CURFy92K4aNF9xC8ik6RDadRAvlw8p3Xc+gWE2un6cc=";

  meta = {
    description = "Daily digest generator from a list of RSS feeds";
    homepage = "https://github.com/piqoni/matcha";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "matcha";
  };
})
