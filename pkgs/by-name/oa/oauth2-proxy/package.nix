{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "oauth2-proxy";
  version = "7.15.3";

  src = fetchFromGitHub {
    owner = "oauth2-proxy";
    repo = "oauth2-proxy";
    rev = "v${version}";
    sha256 = "sha256-HpWmIOqyE3L0JYAQh+bd30Gr2dDpTGH8DwFJo5XwflY=";
  };

  vendorHash = "sha256-o4JWhqLbfHmlIY1XhaupIhYLfXJNguFueH+SpAe9xaw=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # Taken from https://github.com/oauth2-proxy/oauth2-proxy/blob/master/Makefile
  ldflags = [ "-X github.com/oauth2-proxy/oauth2-proxy/v7/pkg/version.VERSION=v${version}" ];

  meta = {
    description = "Reverse proxy that provides authentication with Google, Github, or other providers";
    homepage = "https://github.com/oauth2-proxy/oauth2-proxy/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      swarsel
    ];

    mainProgram = "oauth2-proxy";
  };
}
