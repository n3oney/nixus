{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libdrm,
  lib,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "cyan-skillfish-governor-smu";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "filippor";
    repo = "cyan-skillfish-governor";
    rev = "v${version}";
    hash = "sha256-nhYe7cZGVN7snTKLc8Xgjjfwgqnob7gaUD0IsAC/L4s=";
  };

  cargoHash = "sha256-2CFDNnKGi1fqFKv9RU6lovNHm+LQMBV7ypxbNcbeR6w=";

  env.CYAN_SKILLFISH_GOVERNOR_VERSION = "v${version}";

  nativeBuildInputs = [pkg-config];
  buildInputs = [libdrm];

  postInstall = ''
    install -Dm644 default-config.toml \
      $out/share/${pname}/default-config.toml
    install -Dm644 com.cyan.SkillFishGovernor.conf \
      $out/share/dbus-1/system.d/com.cyan.SkillFishGovernor.conf
    install -Dm755 scripts/cyan-skillfish-performance-mode \
      $out/bin/cyan-skillfish-performance-mode
  '';

  meta = {
    description = "GPU governor for the AMD Cyan Skillfish APU (SMU variant)";
    homepage = "https://github.com/filippor/cyan-skillfish-governor";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "cyan-skillfish-governor-smu";
  };
}
