# Stage 1 Performance Host Profile - 2026-05-10

This file records the local machine used for the current exported-app and headless Stage 1 performance samples.

- Architecture: `arm64`
- CPU: `Apple M1`
- Model: `iMac21,2`
- Memory: `16 GB`
- macOS: `26.5`
- Build: `25F5068a`

Source commands:

```bash
uname -m
sysctl -n machdep.cpu.brand_string hw.model hw.memsize
sw_vers
```

Interpretation: this is local Apple Silicon Mac A evidence. It is not second-machine proof, not distribution proof, and not evidence of performance across the intended minimum hardware matrix.
