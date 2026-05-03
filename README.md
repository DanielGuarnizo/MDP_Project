# MDP — Mapping-Driven Pipeline

End-to-end HLS pipeline: FactorFlow produces dataflow mappings, the MDP code-generator emits C kernels, and Bambu compiles them to RTL for cycle-accurate simulation.

## Setup (two commands)


```bash
# 1. Build image — installs all deps + PandA-bambu from source (~30-60 min)
docker build --platform linux/amd64 --progress=plain -t dev_mdp_image -f Dockerfile.dev .

# 2. Create container — stays on Docker daemon, attach via VSCode or exec
docker run -d -t --platform linux/amd64 --name dev_mdp_container -v "$(pwd)":/workspace dev_mdp_image
```

After that, enter the container with:

```bash
docker exec -it dev_mdp_container bash
```

Start/stop from Docker Desktop or `docker start / docker stop dev_mdp_container`. Attach a VSCode window via **Remote Explorer → Attach to Running Container**.

---

## Usage (inside container, from `/workspace`)

```bash
# Run ex11 and ex12
./scripts/run_conv_single.sh
```

> `src/main.py` must be run from `/workspace` (not from inside `src/`).
