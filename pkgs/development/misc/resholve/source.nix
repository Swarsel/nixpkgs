{
  fetchFromGitHub,
  ...
}:

rec {
  version = "0.10.7";

  rSrc = fetchFromGitHub {
    hash = "sha256-aUhxaxniGcmFAawUTXa5QrWUSpw5NUoJO5y4INk5mQU=";
    owner = "abathur";
    repo = "resholve";
    rev = "v${version}";
  };
}
