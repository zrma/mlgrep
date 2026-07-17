# Agent Harness

## Interface

- Structure ID: `agent-harness-v1`.
- Baseline ID: `openai-gpt-5.6-2026-07-11`.
- Convergence stage: `canonical`.
- Target stage: `canonical`.
- Canonical check: `scripts/check-agent-harness-interface.sh`.
- Publication class: `public`.
- Publication boundary check: `scripts/check-publication-boundary.py`.

`AGENTS.md`가 공통 GPT-5.6 계약을 소유하고, 이 문서는 mlgrep product와 Mallang
application overlay, 현재 작업 문서로 가는 canonical 진입점이다.

Publication class는 저장소의 목표 공개 경계를 선언한다. 실제 공개 저장소 생성과
push는 별도 승인 경계다. 공개 문서에는 checkout 경로, 다른 저장소 inventory, 개인
hostname, 내부 endpoint/IP, local draft 상태를 남기지 않는다.

Tracked artifact contract: raw tool output와 정확한 로컬 환경 evidence는 local-only로
취급한다. 공개 가능한 기록에는 repository-owned 결정, 필요한 명령 이름, redacted
검증 판정만 남기고 경로·호스트·주소·클러스터 값은 placeholder로 바꾼다.

## Project Objective

Mallang v1으로 작성된 작고 예측 가능한 native text search CLI를 제공하고, 실제 외부
프로젝트에서 언어·표준 라이브러리·tooling의 마찰을 지속적으로 검증한다.

## Source Of Truth

- 검색 의미와 summary ADT: `src/search/search.mlg`.
- CLI 인자, 출력과 exit status: `src/main.mlg`.
- 현재 구현과 리스크: `docs/status.md`; 우선순위: `docs/roadmap.md`.
- 무컨텍스트 시작점: `docs/HANDOFF.md`; 현재 작업: 활성 `docs/todo-*.md`.
- 검증 선언: `docs/REPO_MANIFEST.yaml`과 `scripts/check.sh`.
- release identity와 배포 gate: `VERSION`, `scripts/check-release.sh`.

## Autonomy And Permissions

- 목표와 acceptance가 명확한 로컬·가역 작업은 추가 승인 없이 구현, 검증,
  문서화, local `jj` change 정리까지 진행한다.
- 외부 write, secret, 비용, 파괴적 작업, 제품 방향 변경, published history rewrite,
  승인되지 않은 push는 에스컬레이션한다.
- compiler 변경으로 우회하지 않고 공개 Mallang stable contract 안에서 먼저 해결한다.

## Execution Loop

1. `jj status`, handoff/status/roadmap과 활성 todo를 확인한다.
2. search semantics, CLI, harness 중 이번 논리 경계를 고정한다.
3. 재현 가능한 text fixture와 user-visible output을 acceptance로 먼저 정한다.
4. 가장 작은 기능 slice를 구현하고 installed `mlg` focused check를 실행한다.
5. `scripts/check.sh`까지 넓혀 실패를 같은 루프에서 닫는다.
6. 발견한 Mallang friction을 bug, documentation, tooling, future language 후보로 분류한다.
7. 하나의 목적을 가진 `jj` change로 닫고 원격 write 전에는 승인을 받는다.

## Verification And Evidence

- 전체 local gate: `scripts/check.sh`.
- 전체 release gate: `scripts/check-release.sh`; 공개 후 smoke: `scripts/check-published-release.sh`.
- Mallang gate: `mlg fmt --check .`, `mlg check .`, `mlg test .`, native build와 CLI smoke.
- 실제 workload: deterministic large UTF-8 log fixture의 count smoke.
- harness interface: `scripts/check-agent-harness-interface.sh`.
- publication boundary: `scripts/check-publication-boundary.py`; 공개 push 전에는 권한 있는
  machine-local private-inventory gate도 실행한다.
- 최종 evidence에는 compiler version, user-visible output, exit status, 남은 리스크,
  local/remote bookmark 상태를 구분해 포함한다.

## Escalation

검색 semantics 선택, Mallang compatibility를 깨는 언어 변경, credential/private context,
비용, 파괴적 변경, published history rewrite, 승인되지 않은 push가 필요할 때만 사용자에게
최소 판단을 요청한다. 구현 세부사항과 안전한 local 검증은 agent가 직접 결정한다.

## VCS And Publish

- 로컬 VCS는 `jj`를 사용하고 change description은 `<type>: <summary>`와 Codex
  attribution trailer 규칙을 따른다.
- 변경은 independently explainable하고 검증 가능한 milestone 단위로 유지한다.
- push/tag/release는 별도 외부-write 경계이며 명시적 권한 없이 실행하지 않는다.
- 공개 전에는 repository publication gate와 권한 있는 machine-local inventory gate를
  모두 통과한다.

## Harness Evaluation And Improvement

대표 fixture와 large-input smoke에서 완료성, 검색 정확도, output 결정성, exit status,
compile/run latency와 회귀율을 평가한다. 반복 실패는 Mallang test, shell smoke, 검증
스크립트 또는 concise operating rule 중 가장 가까운 계층에 기계화한다.

## Convergence

- `bridge`: 이 문서가 공통 인터페이스를 제공하고 기존 상세 문서를 연결한다.
- `normalized`: autonomy, execution, verification, escalation, VCS 정책을 동일 섹션 계약으로 이동한다.
- `canonical`: 프로젝트 목적과 domain invariant는 local content로 유지하고 공통 baseline, 제목 순서, 검사 골격을 잠근다.
- 단계 전환은 현재 저장소의 Structure ID, 섹션 순서, canonical check 결과로 검증하며 다른 저장소의 이름·개수·로컬 경로·공개 여부를 전제하지 않는다.

## Project Overlay

- v0.2는 UTF-8 streaming literal substring 검색만 지원하며 regex, glob, directory walk는 제외한다.
- 기본 output은 1-based `line:content`; `--count`는 match 수만 출력한다.
- exit status는 match 0, no-match 1, usage/I/O 2다.
- count mode는 per-line output을 만들지 않아야 한다.
- 공개 Mallang release 설치본만 compiler source of truth로 사용한다.
- v0.2.0 streaming I/O release를 닫고 multiple-file search는 v0.3.0으로 순차 진행한다.

## Related Documents

- Navigation: `docs/HANDOFF.md`.
- Current state and direction: `docs/status.md`, `docs/roadmap.md`.
- Completed work: `docs/completed-milestones.md`.
- Mallang consumer findings: `docs/mallang-v1-findings.md`.
- Active work: `docs/todo-v020-streaming-io.md`.
- Escalation: `docs/ESCALATION_POLICY.md`.
- Declared checks: `docs/REPO_MANIFEST.yaml`.
