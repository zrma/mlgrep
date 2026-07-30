## Project Overlay

- v0.3은 여러 explicit UTF-8 파일의 streaming literal substring 검색을 지원하며 regex, glob, directory walk는 제외한다.
- 단일 파일 output은 `line:content`; 여러 파일은 ordered `path:line:content`를 사용한다.
- `--count`는 단일 파일 bare count, 여러 파일 ordered `path:count`를 출력한다.
- exit status는 any match 0, aggregate no-match 1, usage/first I/O error 2다.
- count mode는 per-line output을 만들지 않아야 한다.
- 공개 Mallang release 설치본만 compiler source of truth로 사용한다.
- v0.3.0 이후 commodity grep 기능은 검증된 별도 제품 가설 없이 추가하지 않는다.

## Related Documents

- Navigation: `docs/HANDOFF.md`.
- Current state and direction: `docs/status.md`, `docs/roadmap.md`.
- Completed work: `docs/completed-milestones.md`.
- Mallang consumer findings: `docs/mallang-v1-findings.md`.
- Product boundary: `docs/product-positioning.md`.
- Active work: `docs/todo-v030-multiple-files.md`.
- Escalation: `docs/ESCALATION_POLICY.md`.
- Declared checks: `docs/REPO_MANIFEST.yaml`.
