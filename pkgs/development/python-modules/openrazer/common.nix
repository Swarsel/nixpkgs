{ lib, fetchFromGitHub }:
rec {
  version = "3.12.4";

  src = fetchFromGitHub {
    owner = "openrazer";
    repo = "openrazer";
    tag = "v${version}";
    hash = "sha256-WgDYs0ehnzWlX/wvfur0UhFLbZv7jZ6FMybqDaFDuLg=";
  };

  pyproject = true;

  meta = {
    homepage = "https://openrazer.github.io/";
    changelog = "https://github.com/openrazer/openrazer/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ evanjs ];
    platforms = lib.platforms.linux;
  };
}
