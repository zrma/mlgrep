## Repository Overlay

- 검색 의미와 exit status는 `src/search/search.mlg`, `src/main.mlg`와 테스트를 source of truth로 사용한다.
- Mallang stable compiler `mlg 1.1.0`만 지원 기준으로 사용하고 compiler checkout에 의존하지 않는다.
- 기본 전체 검증은 `scripts/check.sh`; 공개 경계는 `scripts/check-publication-boundary.py`로 확인한다.
- release identity는 `VERSION`, 전체 배포 검증은 `scripts/check-release.sh`가 소유한다.
- v0.3.0 multiple-file 의미는 `docs/todo-v030-multiple-files.md`를 따른다.
- 공개 취약점 제보와 지원 범위는 `SECURITY.md`를 따른다.
- 로컬 VCS는 `jj`를 사용하고 push는 명시적 권한이 있을 때만 수행한다.
