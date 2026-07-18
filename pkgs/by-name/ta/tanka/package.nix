{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "tanka";
  version = "0.37.5";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "tanka";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-jfDaS4kHHfX94dK1pCVyPdesYTZP/9Vzd1y2Sv7Snzw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-gcoUkMygjVVTIaf5Y77ipViaB44/r1MNjJyaUiLafLQ=";
  # Required for versions >= 0.28 as they introduce a gowork.sum file. This is only used for tests so we can safely disable GOWORK
  env.GOWORK = "off";
  doCheck = false;

  postInstall = ''
    echo "complete -C $out/bin/tk tk" > tk.bash

    cat >tk.fish <<EOF

    function __complete_tk
        set -lx COMP_LINE (commandline -cp)
        test -z (commandline -ct)
        and set COMP_LINE "\$COMP_LINE "
        $out/bin/tk
    end
    complete -f -c tk -a "(__complete_tk)"

    EOF

    cat >tk.zsh <<EOF
    #compdef tk
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C $out/bin/tk tk
    EOF

    installShellCompletion \
      --cmd tk \
      --bash tk.bash \
      --fish tk.fish \
      --zsh tk.zsh
  '';

  ldflags = [
    "-s"
    "-w"
    "-extldflags '-static'"
    "-X github.com/grafana/tanka/pkg/tanka.CurrentVersion=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/tk" ];

  meta = {
    description = "Flexible, reusable and concise configuration for Kubernetes";
    homepage = "https://tanka.dev";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "tk";
  };
})
