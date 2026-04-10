ove# Changes Made for ppc64le-Only CI

## Summary
Modified the CI workflow to run ONLY ppc64le jobs on self-hosted runners, skipping all other architectures (amd64, arm64, s390x).

## Files Changed

### 1. `.github/workflows/ci-on-push.yaml` - MODIFIED
**Only 1 line changed (line 38):**

```diff
- uses: ./.github/workflows/ci.yaml
+ uses: ./.github/workflows/ci-ppc64le-only.yaml
```

**That's it!** All other lines remain unchanged. The workflow still:
- Triggers on `pull_request_target` with `ok-to-test` label
- Runs the skipper job
- Passes all the same inputs and secrets
- Works exactly the same way, just calls a different workflow

### 2. `.github/workflows/ci-ppc64le-only.yaml` - NEW FILE
**Purpose:** Simplified CI workflow containing ONLY ppc64le jobs

**Jobs included:**
1. `build-kata-static-tarball-ppc64le` - Builds Kata components for ppc64le
2. `publish-kata-deploy-payload-ppc64le` - Publishes container images  
3. `run-k8s-tests-on-ppc64le` - Runs Kubernetes tests
4. `run-cri-containerd-tests-ppc64le` - Runs containerd CRI tests

**Key features:**
- Accepts all the same secrets as the original workflow (for compatibility)
- Only uses `QUAY_DEPLOYER_PASSWORD` (others are ignored)
- Uses self-hosted runners: `ubuntu-24.04-ppc64le`, `ppc64le-k8s`, `ppc64le-small`
- Respects `skip-test` input from skipper
- Runs containerd tests by default (can be disabled if needed)

## What This Achieves

✅ **Runs ONLY ppc64le jobs** - No amd64, arm64, s390x, Azure, GPU, or CoCo tests  
✅ **Uses self-hosted runners** - All jobs run on your ppc64le machines  
✅ **Minimal changes** - Only 1 line changed in existing workflow  
✅ **Backward compatible** - Accepts all original secrets (uses only what's needed)  
✅ **Same trigger mechanism** - Still uses `ok-to-test` label on PRs

## What You Need to Do

### 1. Set Up Self-Hosted Runners
Configure your ppc64le runner(s) with these labels:
- `ubuntu-24.04-ppc64le` - for build jobs
- `ppc64le-k8s` - for Kubernetes tests  
- `ppc64le-small` - for containerd tests

**Tip:** You can add all 3 labels to a single runner if you only have one machine.

**Setup command:**
```bash
cd ~/actions-runner
./config.sh --url https://github.com/YOUR_USERNAME/kata-containers \
  --token YOUR_TOKEN \
  --labels ubuntu-24.04-ppc64le,ppc64le-k8s,ppc64le-small
```

### 2. Add Required Secret
In your fork: **Settings → Secrets and variables → Actions → New repository secret**

- **Name:** `QUAY_DEPLOYER_PASSWORD`
- **Value:** Your quay.io password

**Note:** If you don't want to publish to quay.io, you can:
- Use a dummy value (the build will work, publish might fail but tests will still run)
- Or modify the workflow to skip publishing

### 3. Add Dummy Values for Other Secrets (Optional)
The workflow accepts these secrets for compatibility but doesn't use them:
- `AUTHENTICATED_IMAGE_PASSWORD`
- `AZ_APPID`, `AZ_TENANT_ID`, `AZ_SUBSCRIPTION_ID`
- `CI_HKD_PATH`
- `ITA_KEY`
- `NGC_API_KEY`
- `KBUILD_SIGN_PIN`

You can either:
- **Option A:** Add them with dummy values like `"not-needed"` (prevents errors if they're checked)
- **Option B:** Don't add them (workflow will work fine, they're marked as `required: false`)

### 4. Test the Workflow
1. Create a PR in your fork
2. Add the `ok-to-test` label
3. Watch the workflow run only ppc64le jobs!

## How It Works

```
Pull Request with 'ok-to-test' label
         ↓
   ci-on-push.yaml (modified)
         ↓
   gatekeeper-skipper.yaml (unchanged)
         ↓
   ci-ppc64le-only.yaml (NEW - only ppc64le jobs)
         ↓
   ├── build-kata-static-tarball-ppc64le.yaml
   ├── publish-kata-deploy-payload.yaml (ppc64le)
   ├── run-k8s-tests-on-ppc64le.yaml
   └── run-cri-containerd-tests.yaml (ppc64le)
```

## Jobs That Will Run

### Phase 1: Build and K8s Tests (Always runs)
1. **Build** (`ubuntu-24.04-ppc64le` runner)
   - Builds: agent, kernel, qemu, virtiofsd, rootfs-initrd, shim-v2
   - Creates kata-static tarball
   - ~30-60 minutes

2. **Publish** (`ubuntu-24.04-ppc64le` runner)
   - Publishes container image to ghcr.io
   - ~5-10 minutes

3. **K8s Tests** (`ppc64le-k8s` runner)
   - Deploys Kata on your existing K8s cluster
   - Runs integration tests
   - ~30 minutes

### Phase 2: Containerd Tests (Always runs)
4. **Containerd Tests** (`ppc64le-small` runner)
   - Creates/destroys K8s cluster
   - Tests containerd CRI integration
   - ~30-45 minutes

**Total time:** ~1.5-2.5 hours (depending on your hardware)

## Disabling Containerd Tests

If you want to skip containerd tests (Phase 2) to avoid cluster creation/destruction:

Edit `.github/workflows/ci-ppc64le-only.yaml` line 91:
```yaml
# Change from:
if: ${{ inputs.skip-test != 'yes' }}

# To:
if: false
```

Or add a condition:
```yaml
if: ${{ inputs.skip-test != 'yes' && github.event.pull_request.labels.*.name contains 'run-containerd-tests' }}
```

## Reverting Changes

To go back to the original workflow:

1. Edit `.github/workflows/ci-on-push.yaml` line 38:
   ```yaml
   uses: ./.github/workflows/ci.yaml
   ```

2. Optionally delete `.github/workflows/ci-ppc64le-only.yaml`

## Troubleshooting

### Workflow doesn't start
- Ensure `ok-to-test` label is added to PR
- Check runners are online: Settings → Actions → Runners
- Verify workflow syntax: Actions tab → select workflow → check for errors

### Build fails with "runner not found"
- Check runner labels match exactly: `ubuntu-24.04-ppc64le`, `ppc64le-k8s`, `ppc64le-small`
- Verify runners are online and idle
- Restart runner: `sudo ~/actions-runner/svc.sh restart`

### Secret errors
- Add `QUAY_DEPLOYER_PASSWORD` in repository settings
- Or use dummy value if not publishing

### K8s tests fail
- Ensure cluster is healthy: `kubectl get nodes`
- Check required scripts exist: `ls -la ~/scripts/k8s_cluster_*.sh`
- Verify runner has `ppc64le-k8s` label

### Containerd tests fail
- Ensure runner can create/destroy clusters
- Check for port conflicts or resource constraints
- Review logs in Actions tab

## Documentation

- **Quick Start:** [`ppc64le-ci-quick-start.md`](./ppc64le-ci-quick-start.md)
- **Detailed Plan:** [`ppc64le-ci-setup-plan.md`](./ppc64le-ci-setup-plan.md)
- **K8s Setup:** [`ppc64le-weekly-sanity-setup.md`](./ppc64le-weekly-sanity-setup.md)

## Next Steps

1. ✅ Code changes are complete
2. ⏳ Set up self-hosted runners with labels
3. ⏳ Add `QUAY_DEPLOYER_PASSWORD` secret
4. ⏳ Test with a PR
5. ⏳ Monitor and adjust as needed

Good luck! 🚀