# Working in skills-os

This repository contains reusable skills. See [shared/guidebook.md](shared/guidebook.md)
for the layout and build command.

- Keep each skill's name and description in its `SKILL.md` YAML frontmatter.
- Keep workflow instructions focused on the skill's stated purpose.
- Edit shared resources in `shared/`, then run `./build.sh` to refresh their copies.
- Add supporting material to a skill's `references/` directory when needed and
  link it from that skill's instructions.
