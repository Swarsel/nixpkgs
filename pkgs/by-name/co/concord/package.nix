{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "concord";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "Cogmasters";
    repo = "concord";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yTFGRnhDzxU+dPeZbCWlm52gsmEgD2el+46c8XQBQng=";
  };

  buildInputs = [ curl ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Discord API wrapper library made in C";
    homepage = "https://cogmasters.github.io/concord/";
    changelog = "https://github.com/Cogmasters/concord/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.unix;
  };
})
