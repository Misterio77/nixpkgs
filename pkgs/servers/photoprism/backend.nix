{ buildGoModule, coreutils, libtensorflow, src, version, ... }:

buildGoModule rec {
  inherit src version;
  pname = "photoprism-backend";

  buildInputs = [
    coreutils
    libtensorflow
  ];

  postPatch = ''
    substituteInPlace internal/commands/passwd.go --replace '/bin/stty' "${coreutils}/bin/stty"
  '';

  vendorSha256 = "sha256-GaMV1SFDTCgZMZz0lYAKqqqX5zW+pU39vnwtlz2UDbQ=";

  subPackages = [ "cmd/photoprism" ];

  # https://github.com/mattn/go-sqlite3/issues/822
  CGO_CFLAGS = "-Wno-return-local-addr";

  # https://github.com/tensorflow/tensorflow/issues/43847
  CGO_LDFLAGS = "-fuse-ld=gold";
}
