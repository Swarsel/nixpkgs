rec {
  bzip2 = {
    executable = pkgs: "${pkgs.bzip2}/bin/bzip2";
    extension = ".bz2";
  };

  cat = {
    executable = pkgs: "cat";
    extension = ".cpio";
  };

  gzip = {
    defaultArgs = [ "-9n" ];
    executable = pkgs: "${pkgs.gzip}/bin/gzip";
    extension = ".gz";
  };

  lz4 = {
    defaultArgs = [ "-l" ];
    executable = pkgs: pkgs.lib.getExe pkgs.lz4;
    extension = ".lz4";
  };

  lzma = {
    defaultArgs = [
      "--check=crc32"
      "--lzma1=dict=512KiB"
    ];

    executable = pkgs: "${pkgs.xz}/bin/lzma";
    extension = ".lzma";
  };

  lzop = {
    executable = pkgs: "${pkgs.lzop}/bin/lzop";
    extension = ".lzo";
  };

  pigz = gzip // {
    executable = pkgs: "${pkgs.pigz}/bin/pigz";
  };

  pixz = xz // {
    defaultArgs = [ ];
    executable = pkgs: "${pkgs.pixz}/bin/pixz";
  };

  xz = {
    defaultArgs = [
      "--check=crc32"
      "--lzma2=dict=512KiB"
    ];

    executable = pkgs: "${pkgs.xz}/bin/xz";
    extension = ".xz";
  };

  zstd = {
    defaultArgs = [ "-10" ];
    executable = pkgs: "${pkgs.zstd}/bin/zstd";
    extension = ".zst";
  };
}
