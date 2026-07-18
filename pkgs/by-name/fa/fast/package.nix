{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "fast";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "maaslalani";
    repo = "fast";
    tag = "v${version}";
    hash = "sha256-/Li5AAuuHkVqJzmh38g5CPQXWj4RY0TRwvtjlpydosg=";
  };

  vendorHash = "sha256-YSjJ8NOL97hXZLnfGYIjoKmARv+gWOsv+5qkl9konnA=";
  __structuredAttrs = true;

  meta = {
    description = "Internet speed test in your terminal";
    homepage = "https://github.com/maaslalani/fast";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yarn ];
    platforms = lib.platforms.unix;
    mainProgram = "fast";
  };
}
