# Mallang v1 External Consumer Findings

검증 기준은 공개 배포된 `mlg 1.0.0`이다. 이 문서는 컴파일러 저장소를 수정하지 않고
외부 네이티브 CLI를 구현하면서 확인한 언어 및 표준 라이브러리 경계를 기록한다.

## Borrowed strings from slices

`strings.split`이 반환한 `[]string`의 원소는 `Copy`가 아니므로 인덱싱한 문자열을
소유 결과 컬렉션으로 이동할 수 없다. 이 제약은 안전한 소유권 규칙과 일치하지만,
검색 결과 전체를 하나의 문자열로 조립하는 설계에는 직접적인 압력을 준다.

`mlgrep`은 검색 코어가 `Summary` 값을 반환하고 CLI가 일치한 줄을 빌린 상태로 여러 번
출력하도록 경계를 정했다. 향후 실제 소비자 사례가 더 쌓이면 명시적 문자열 복제 또는
borrow-preserving formatting/writev API가 필요한지 판단할 수 있다.

## Split and physical lines

비어 있지 않은 구분자로 `strings.split`을 호출하면 마지막 구분자 뒤의 빈 필드도 보존된다.
따라서 개행으로 끝나는 파일을 빈 패턴으로 검색할 때 마지막 빈 필드를 물리적인 새 줄로
간주하지 않도록 소비자가 보정해야 한다. `LineCount`와 terminal-newline 회귀 테스트로 이
동작을 제품 계약에 고정했다.

## Whole-file I/O

현재 공개 파일 API는 `fs.readText` 중심이므로 검색 전에 전체 UTF-8 파일을 메모리에 올린다.
v0.1의 100,000줄 결정적 smoke에는 충분하지만, 입력 크기가 커질수록 최대 메모리는 파일
크기와 분할된 문자열 저장 비용에 비례한다. streaming은 추측으로 추가하지 않고 실제 한계가
측정될 때 Mallang의 reader API와 함께 다음 마일스톤으로 다룬다.
