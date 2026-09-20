<!-- GENERATED FILE — do not edit. Source: shared/platform.notconfigured.md. Run ./build.sh to regenerate. -->

# Platform Standards — NOT CONFIGURED

`shared/platform.md` does not exist in this project, so Guidebook §17 is unanswered.

**Consequence for auditing.** These guidebook rules cannot be assessed concretely. Report each as a
finding against §17 — do NOT invent platform mechanics:

| Guidebook rule | Blocked because |
|---|---|
| §2.2 classification corroboration | no data classification tooling declared |
| §5.3 use shared packages | no canonical package list declared |
| §7.3 event-triggered, not polled | no event-trigger mechanism declared |
| §11.2 post-deploy verification | no deploy commands declared |

**Remediation.** Run `/so-init`, or copy `shared/platform.example.md` to `shared/platform.md` and
fill it in, then run `./build.sh`.
