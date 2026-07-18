{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
  gnupg,
  less,
  nix-update-script,
  openssh,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gittuf";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "gittuf";
    repo = "gittuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VWbM7y9XCs/pANJtPa3MDbDhuEtVQ97X5Cyo6yY0Rd8=";
  };

  strictDeps = true;
  vendorHash = "sha256-VTfS0bLq7B037qmFABO5JDrV98zik5ycR4s6NZr3H4s=";

  nativeCheckInputs = [
    git
    gnupg
    less
    openssh
  ];

  checkFlags = [ "-skip=TestLoadRepository|TestSSH" ];
  postInstall = "rm $out/bin/cli $out/bin/sandbox"; # remove gendoc helper binaries
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  ldflags = [ "-X github.com/gittuf/gittuf/internal/version.gitVersion=${finalAttrs.version}" ];
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Security layer for Git repositories";
    homepage = "https://gittuf.dev";
    changelog = "https://github.com/gittuf/gittuf/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      flandweber
      anish
    ];

    mainProgram = "gittuf";
  };
})
