# Mallang v1 External Consumer Findings

현재 검증 기준은 공개 배포된 `mlg 1.1.0`이다. 이 문서는 컴파일러 저장소를 수정하지 않고
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

v0.1은 `fs.readText`와 `strings.split`으로 전체 UTF-8 파일과 분할 문자열을 메모리에
올렸다. 100 MiB 관찰에서 peak RSS가 약 233.5 MiB까지 증가해 streaming 필요를 확인했다.

Mallang 1.1.0의 `fs.forEachLine[C,S]`는 file handle이나 borrowed return을 노출하지 않고
pattern context와 mutable search state를 한 synchronous call에 빌려준다. v0.2는 이 API로
whole-file runtime path를 제거했다. 1/10/100 MiB current 측정의 peak RSS는 약 1.3 MiB로
유지되며, invalid UTF-8와 open/read failure는 기존 exit class 2로 매핑된다.
