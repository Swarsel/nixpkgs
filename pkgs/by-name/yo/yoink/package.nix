{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "1.0.1";
in
buildGoModule {
  inherit version;
  pname = "yoink";

  src = fetchFromGitHub {
    owner = "MrMarble";
    repo = "yoink";
    rev = "v${version}";
    hash = "sha256-yI3koHVeZWkujpiO0qLj1i4m5l5BiZNZE5ix+IKFwyc=";
  };

  vendorHash = "sha256-P1bkugMaVKCvVx7y8g/elsEublHPA0SgeKzWiQCi4vs=";

  meta = {
    description = "Automatically download freeleech torrents";
    homepage = "https://github.com/MrMarble/yoink";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hogcycle ];
  };
}
