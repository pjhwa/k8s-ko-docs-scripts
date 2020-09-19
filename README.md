# k8s-ko-docs-scripts

한글화 번역 작업을 위한 스크립트입니다.

## For maintaining translated documents

### find-l10n-links.sh

한글로 번역된 문서 중에서 다음을 찾아줍니다.
- 이미 번역된 문서 대신 영문 문서를 가리키고 있는 부분을 찾아줍니다.
- website/static/_redirects 에 포함된 URL(이미 한글 번역이 되어있는 문서로의)이 있는 부분을 찾아줍니다.

website/ 디렉터리에서 스크립트를 수행하면, website 상위 디렉터리에 foundlinks-ko.txt, foundlinks-rd-ko.txt 파일이 생성됩니다.

결과 파일의 샘플은 아래와 같습니다. (샘플 결과 파일은 results/ 디렉터리를 참고하세요.)

```
===============================================================================================
=== /ko/docs/contribute/review/for-approvers/ 
===============================================================================================
docs/contribute/new-content/open-a-pr.md:289:또한 GitHub는 리뷰어에게 도움을 주기 위해 PR에 레이블을 자동으로 할당한다. 필요한 경우 직접 추가할 수도 있다. 자세한 내용은 [이슈 레이블 추가와 제거](/docs/contribute/review/for-approvers/#adding-and-removing-issue-labels)를 참고한다.
-----------------------------------------------------------------------------------------------

------ /ko/docs/contribute/new-content/open-a-pr.md @ line 289 ::
/docs/contribute/review/for-approvers/#adding-and-removing-issue-labels

------ Select one of the following anchors of /ko/docs/contribute/review/for-approvers/ ::
#pr-리뷰
#다른-사람의-pr에-커밋
#리뷰를-위한-prow-명령
#이슈-심사와-분류
#이슈-심사
#이슈-레이블-추가와-제거
#이슈의-lifecycle-레이블
#특별한-이슈-유형의-처리
#중복된-이슈
#깨진-링크-이슈
#블로그-이슈
#지원-요청-또는-코드-버그-리포트
-------------------------------------------------------------------------------------------
```
